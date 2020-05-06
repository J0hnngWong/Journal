//
//  DatabaseManager.swift
//  Journal
//
//  Created by 王嘉宁 on 2020/4/22.
//  Copyright © 2020 Johnny. All rights reserved.
//

import Foundation

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    var dbPointer: OpaquePointer? = nil
    let tableName: String = "journal_list"
    
    func openDB() -> Bool {
        guard let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else { return false }
        let fileName = filePath.hasSuffix("/") ? "\(filePath)JournalDatabase" : "\(filePath)/JournalDatabase"
        if !FileManager.default.fileExists(atPath: fileName) {
            FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
        }
        return sqlite3_open(fileName.cString(using: .utf8), &dbPointer) == SQLITE_OK
    }
    
    func execSql(_ sql: String) -> Bool {
        let cSql = sql.cString(using: .utf8)
        return sqlite3_exec(dbPointer, cSql, { (notUsed, argc, argv, azColName) -> Int32 in
            for i in 0...argc {
                print("%s = %s\n", azColName?[Int(i)], (argv?[Int(i)] != nil) ? argv?[Int(i)] : "NULL");
            }
            return 0
        }, nil, nil) == SQLITE_OK
    }
    
    func createTable(tableName: String, parameterList: [String:Any]) -> Bool {
        let sql = "CREATE TABLE IF NOT EXISTS '\(tableName)' ('id' text NOT NULL PRIMARY KEY, 'title' text, 'detail' text, 'image_name' text, 'create_date' date, 'last_update_date' date);"
        return execSql(sql)
    }
    
    func InsertData(model: JournalModel) -> Bool {
        let sql = "INSERT INTO '\(tableName)' VALUES ('\(model.id)', '\(model.title)', '\(model.detail)', '\(model.imageName)', '\(model.createDate)', '\(model.lastUpdateDate)')"
        return execSql(sql)
    }
    
    func deleteData(id: UUID) -> Bool {
        let sql = "DELETE FROM '\(tableName)' WHERE id='\(id)'"
        return execSql(sql)
    }
    
    func updateData(model: JournalModel) -> Bool {
        let sql = "UPDATE '\(tableName)' set title='\(model.title)', detail='\(model.detail)', image_name='\(model.imageName)', create_date='\(model.createDate)', last_update_date='\(model.lastUpdateDate)' WHERE id='\(model.id)'"
        return execSql(sql)
    }
}
