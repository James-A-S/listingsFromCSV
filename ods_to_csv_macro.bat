REM Listings in the comments - http://www.pitonyak.org/oo.php
Sub exportToCSV()
Dim sURL$ As String ' URL of current workbook
Dim CSVfile As String ' URL of target CSV-file
Dim Docpath$ As String ' My new variable - path of document
'Dim oCurrentController As Object ' Before save - activate sheet sSheetName
Dim storeParms(2) as new com.sun.star.beans.PropertyValue 
'Const sSheetName = "TO_CSV"
   SheetName = ThisComponent.getCurrentController().getActiveSheet().getName()
   GlobalScope.BasicLibraries.LoadLibrary("Tools") ' Only for GetFileName
   sURL = thisComponent.getURL()
   CSVfile = GetFileNameWithoutExtension(sURL) & "_" & Sheetname & ".csv"
   Docpath = Tools.Strings.DirectoryNameoutofPath(ThisComponent.url, "/") & "/" ' path assigned
REM Options to StoreTo:
   storeParms(0).Name = "FilterName"
   storeParms(0).Value = "Text - txt - csv (StarCalc)" 
REM See name of your filter vs Listing 5.45: Enumerate all supported filter names.
   storeParms(1).Name = "FilterOptions"
   storeParms(1).Value = "44,34,76,1,,0,true,true,true"
REM About this string see 12.4.6.Loading and saving documents in "OOME_3_0"
   storeParms(2).Name = "Overwrite"
   storeParms(2).Value = True 
REM Activate sheet for export - select "To_CSV"
  ' thisComponent.getCurrentController().setActiveSheet(thisComponent.getSheets().getByName(sSheetName)) ' Force specific sheet 'sSheetName' to become active
REM storeToURL can raises com.sun.star.io.IOException! Only now:
On Error GoTo Errorhandle
REM Export
   thisComponent.storeToURL(CSVfile,storeParms())
   MsgBox ("No Error Found,Upload file is saved : """ + ConvertFromUrl(CSVfile) + """.")
REM run ruby script after save & export
   Shell("/home/james/github/ruby_utils/listingcreator/listingcreator.rb",2,Docpath & " " & SheetName)
   'MsgBox ("My script ran, params: """ + Docpath & " " & SheetName + """.")
Exit Sub
Errorhandle:
    MsgBox ("Modifications Are Not Saved,Upload File Not Generated" & chr(13) _
    & "May be table " & ConvertFromUrl(CSVfile) & " is open in another window?")
    Exit Sub
    Resume
End Sub
