

import Foundation
import UIKit

class SqLiteHelper{

    var photoDB :COpaquePointer = nil;
    var insertStatement :COpaquePointer = nil;
    var selectStatement :COpaquePointer = nil;
    var updateStatement :COpaquePointer = nil;
    var deleteStatement :COpaquePointer = nil;
    var photoDbDetails : [FlickrPhoto] = [];
    
    func open( docsDir : String)
    {
        println(docsDir);
        if( sqlite3_open(docsDir,&photoDB) == SQLITE_OK)
        {
            var sql = "CREATE TABLE IF NOT EXISTS PHOTOS(ID INTEGER PRIMARY KEY AUTOINCREMENT,IMAGENAME TEXT,COMMENT TEXT)";
            var statement : COpaquePointer = nil;
            if(sqlite3_exec(photoDB , sql , nil,nil,nil) != SQLITE_OK)
            {
                println("Error in creating table");
                println( sqlite3_errmsg(photoDB));
            }
        }
        else
        {
            println("failed to open database");
            println( sqlite3_errmsg(photoDB));
        }
        prepareStatement();
    }
    
    func prepareStatement()
    {
        var sqlString : String;
        sqlString = "INSERT INTO photos(imagename,comment) values(?,?)";
        var csql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding);
        sqlite3_prepare(photoDB, csql!, -1, &insertStatement, nil);
        
        sqlString = "SELECT imagename,comment FROM photos";
        csql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding);
        sqlite3_prepare(photoDB, csql!, -1, &selectStatement, nil);
        
        sqlString = "UPDATE photos SET comment=? WHERE imagename=?";
        csql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding);
        sqlite3_prepare(photoDB, csql!, -1, &updateStatement, nil);
        
        sqlString = "DELETE FROM photos WHERE imagename=?";
        csql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding);
        sqlite3_prepare(photoDB, csql!, -1, &deleteStatement, nil);
    }
    
    func createPhoto(imageName : String , comment : String)
    {
        var imageName_String = (imageName as NSString).UTF8String;
        sqlite3_bind_text(insertStatement,1,imageName_String,-1,nil);
        var comment_String = (comment as NSString).UTF8String;
        sqlite3_bind_text(insertStatement,2,comment_String,-1,nil);
        if(sqlite3_step(insertStatement) == SQLITE_DONE)
        {
            println("process completed");
        }
        else
        {
            println(sqlite3_errmsg(photoDB));
        }
        sqlite3_reset(insertStatement);
        sqlite3_clear_bindings(insertStatement);
    }
    
    func selectPhoto() ->[FlickrPhoto]
    {
        while(sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            var photoDbObj = FlickrPhoto();
            var imageName_buf = sqlite3_column_text(selectStatement,0);
            photoDbObj.title = (String.fromCString(UnsafePointer<CChar>(imageName_buf))!);
            var comment_buf = sqlite3_column_text(selectStatement,1);
            photoDbObj.comments = (String.fromCString(UnsafePointer<CChar>(comment_buf))!);
            photoDbDetails.append(photoDbObj);
        }
        return photoDbDetails;
    }
    
    func deletePhoto(imageName : String)
    {
        sqlite3_bind_text(deleteStatement , 1,imageName , -1,nil);
        if(sqlite3_step(deleteStatement) == SQLITE_DONE)
        {
            println("Delete Operation completed");
        }
        else
        {
            println(sqlite3_errmsg(photoDB));
        }
        sqlite3_reset(deleteStatement);
        sqlite3_clear_bindings(deleteStatement);
    }
    
    func updatePhoto(imageName : String , comment : String)
    {
        var comment_String = (comment as NSString).UTF8String;
        sqlite3_bind_text(updateStatement,1,comment_String , -1,nil);
        sqlite3_bind_text(updateStatement,2,imageName , -1,nil);
        if(sqlite3_step(updateStatement) == SQLITE_DONE)
        {
            println("Update Operation completed");
        }
        else
        {
            println(sqlite3_errmsg(photoDB));
        }
        sqlite3_reset(updateStatement);
        sqlite3_clear_bindings(updateStatement);
    }
}

