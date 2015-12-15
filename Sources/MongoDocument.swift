//
//  MongoDocument.swift
//  swiftMongoDB
//
//  Created by Dan Appel on 8/20/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

#if os(Linux)
import CMongoC
#else
import mongoc
#endif

public class MongoDocument {

    let bson: bson_t

    public var JSONString: String? {
        return JSON.from(data)?.description
    }

    public var dataWithoutObjectId: DocumentData {
        var copy = self.data
        copy["_id"] = nil
        return copy
    }

    public var data: DocumentData {
        return self.documentData
    }

    public var id: String? {
        return nil
//        return self.data["_id"]?["$oid"] as? String
    }

    private let documentData: DocumentData

    public init(data: DocumentData) throws {
        self.documentData = data

        do {
            self.bson = try MongoBSON(data: data).bson
        } catch {
            self.bson = bson_t()
            throw error
        }
    }

    convenience public init(JSONString: String) throws {

        let data = try JSONString.parseJSONDocumentData()

        try self.init(data: data)
    }

    convenience public init(withSchemaObject object: MongoObject) throws {

        let data = object.properties()

        try self.init(data: data)
    }

    private func generateObjectId() -> String {

        var oidRAW = bson_oid_t()

        bson_oid_init(&oidRAW, nil)


        let oidStrRAW = UnsafeMutablePointer<Int8>.alloc(100)
//        try to minimize this memory usage while retaining safety, reference:
//        4 bytes : The UNIX timestamp in big-endian format.
//        3 bytes : The first 3 bytes of MD5(hostname).
//        2 bytes : The pid_t of the current process. Alternatively the task-id if configured.
//        3 bytes : A 24-bit monotonic counter incrementing from rand() in big-endian.


        bson_oid_to_string(&oidRAW, oidStrRAW)

        let oidStr = String.fromCString(oidStrRAW)
        //let oidStr = String.fromCString(UTF8String: oidStrRAW)

        oidStrRAW.destroy()

        return oidStr!
    }

    deinit {
//        self.BSONRAW.destroy()
    }
}
