library(XML)
library(rvest)
library(stringr)
library(dplyr)
.cached_tables=list()
.cached_titles=list()

get_rows = function(row){
        print("ok")
        if(class(row)==class(list())){
                print("ok")
        }
        xmlvalues=xpathApply(row, './/td', namespaces=namespaces)
        if(length(xmlvalues)>0){
                rows=gsub("\\n"," ",str_trim(lapply(xmlvalues,xmlValue)))
                return(rows)
        }
}

get_table = function(t){
        header=xpathApply(t, './/th',xmlValue)
        header=gsub("\\n"," ",str_trim(header))
        ncol=length(header)
        if(ncol > 0){
                values=xpathApply(t, './/td')
                values=gsub("\\n"," ",str_trim(lapply(values,xmlValue)))
                dt=data.frame(matrix(values,ncol=length(header),byrow=TRUE))
                colnames(dt)=header
                if(dim(dt)[1]*dim(dt)[2] > 0) return(dt)
        }
        return(data.frame(Results="No Table Found"))
}

get_db_from_web=function(url){
        if(!is.null(.cached_tables[[url]])){
                title.html=.cached_titles[[url]]
                db=.cached_tables[[url]]
        }
        else{
                filename=paste0("tables/",digest(url))
                if(!file.exists(filename)){
                        download.file(url, filename)
                }
                site.html <- scan(file=filename,what="character")
                parse.html <- htmlTreeParse(site.html,useInternalNodes = T,ignoreBlanks = F)
                namespaces=c(xmlns="http://www.w3.org/1999/xhtml")
                tables.html <- xpathApply(parse.html, '//table')
                title.html <- gsub("\n"," ",xpathApply(parse.html, '//title[1]',xmlValue))
                tables <- lapply(tables.html, get_table)
                valid=which(lapply(tables,function(t){t[["Results"]][1]=="No Table Found"})!="TRUE")
                db=tables[[valid[1]]]
                db$tableid=1
                c=1
                ncol=(length(colnames(db)))
                for(i in 2:length(valid)){
                        ndb=tables[[valid[i]]]
                        lncol=length(colnames(ndb))
                        if(ncol==lncol){
                                c=c+1
                                ndb$tableid=c
                                print(lncol)
                                db=rbind(db,ndb)
                        }
                }
                .cached_tables[[url]]=db
                .cached_titles[[url]]=title.html
        }
        list(title.html,db)
}