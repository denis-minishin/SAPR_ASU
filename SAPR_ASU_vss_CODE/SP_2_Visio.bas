Attribute VB_Name = "SP_2_Visio"
'------------------------------------------------------------------------------------------------------------
' Module        : SP - ������������
' Author        : gtfox
' Date          : 2019.09.22
' Description   : spDEL - ������� ����� ������������
                ' spADD_Excel_Razbienie - ��������� ����� ������������ �� Excel �� ����� SP_2_Visio (����� ��������� �� ������)
                ' spADD_Visio_Perenos - ��������� ����� ������������ �� Excel �� ����� SP (������� ������� ����� ������ �����)
                ' spEXP_2_XLS � ������������ ������������ �� Visio � Excel
                ' SP_2_Visio.xls -������������
                ' ���� SP �������� �������� ������������, � ������������� ������� � ����� ������.
                ' ���� SP_2_Visio ��������� ������������� � �������� ���� SP � ����������� ������������� �������� (� ���������� �� ������������ + ���������������� ��� ������ ������ �������)
                ' ���� EXP_2_XLS �������� ���������������� �� Visio ������������ (���� �� ������� ��������� � ������������ � ����� Visio) ��������� ������������� �������� + ���������������� ��� ������ ������ �������
                ' �������� �������� ������������ � ������� ������, ������� ���� ���������/����������.
                ' � Surrogate ������� ������ Visio, � ������ ������ ������������ ������ ������ ShapeSheet. � 2007 ������ VBA ����������� ������� ��������� ������ � ShapeSheet � ������ �� �������� ������ �������. ����������
                ' � ����� ��������� ������ � Excel, � ����� � Visio �� ���� ������� ������ ����� ShapeSheet.
                ' ������� ������������� ������ �� ������ ���������� �� ������ ����������� ���������� ����� ������� � Excel. ������ ������ �������������� � �������� ������� �����. �� �����������, ����� ���������� � ������. � ������������ �������� ��, ��� �� ����� ���������� �������� � ������ ������������ ������ � ���� �������������� ����� ���������.
                ' ������ ������� �� ������ singleTextCellToRows https://www.planetaexcel.ru/forum/index.php?PAGE_NAME=message&FID=1&TID=77447&TITLE_SEO=77447-perenos-teksta-na-sleduyushchuyu-stroku-pri-zapolnenii-stolbtsa-po-shi&MID=841387#message841387
' Link          : https://visio.getbb.ru/viewtopic.php?p=14130, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------
                '�� ������ �����:
                '------------------------------------------------------------------------------------------------------------
                ' Module    : speka2003 ������������
                ' Author    : Surrogate
                ' Date      : 07.11.2012
                ' Purpose   : ������������: ������� ������ �� Excel �� Visio � �������
                '           : ������ ��� �������� ������ �� ������ � �����, ��� ������������ ������������
                ' Links     : https://visio.getbb.ru/viewtopic.php?f=15&t=234, https://visio.getbb.ru/download/file.php?id=106
                '------------------------------------------------------------------------------------------------------------

Option Base 1
'Option Explicit
Dim tabl(1 To 1000, 1 To 9) As Variant
Dim arr() As Variant
Dim str As Integer
Dim pNumber As Integer
Dim rc As Integer
Dim sc As Integer
Dim xx As Integer
Dim yx As Integer
Dim pth As String

Public Sub spDEL()
    del_sp
    'MsgBox "������ ������ ������������ �������", vbInformation
End Sub

'Public Sub spDEL_ADD()
'    del_sp
'    spADD
'End Sub

Public Sub spADD_Excel_Razbienie()
    xls_query "SP_2_Visio"
    fill_table False
    Application.ActiveWindow.Page = Application.ActiveDocument.Pages.Item("�")
    MsgBox "������������ ���������", vbInformation
End Sub

Public Sub spADD_Visio_Perenos()
    xls_query "SP"
    fill_table True
    Application.ActiveWindow.Page = Application.ActiveDocument.Pages.Item("�")
    MsgBox "������������ ���������", vbInformation
End Sub

Private Sub xls_query(imya_lista As String)
    Dim oExcel As Excel.Application
    Set oExcel = CreateObject("Excel.Application")
    Dim sp As Excel.Workbook
    Dim sht As Excel.Sheets
    Dim tr As Object
    Dim tc As Object
    Dim qx As Integer
    Dim qy As Integer
    pth = Visio.ActiveDocument.Path
    Dim ffs As FileDialogFilters
    Dim sFileName As String
    oExcel.Visible = True ' ��� �����������
    Dim fd As FileDialog
'    Set fd = oExcel.FileDialog(msoFileDialogOpen)
'    With fd
'        .AllowMultiSelect = False
'        .InitialFileName = pth
'        Set ffs = .Filters
'        With ffs
'            .Clear
'            .Add "Excel", "*.xls"
'        End With
'        oExcel.FileDialog(msoFileDialogOpen).Show
'    End With
    

    
    Dim sPath, sFile As String
    sPath = pth
    sFileName = "SP_2_Visio.xls"
    sFile = sPath & sFileName
    
    If Dir(sFile, 16) = "" Then '���� ���� �� ���� ����
        MsgBox "���� " & sFileName & " �� ������ � �����: " & sPath, vbCritical, "������"
        Exit Sub
    End If
    
    Set sp = oExcel.Workbooks.Open(sFile)
    sp.Activate
    Dim UserRange As Excel.Range
    Dim Total As Excel.Range ' �������� Full_list
    
    On Error Resume Next
    If oExcel.Worksheets(imya_lista) Is Nothing Then
        '��������, ���� ����� ���
        oExcel.Run "'SP_2_Visio.xls'!Spec_2_Visio.Spec_2_Visio" '�������
    Else
        '��������, ���� ���� ����
    End If
    
    'oExcel.GoTo Reference:=sp.Worksheets(1).Range("A2")
    'oExcel.ActiveCell.Select
    lLastRow = oExcel.Sheets(imya_lista).Cells(oExcel.Sheets(imya_lista).Rows.Count, 1).End(xlUp).Row
    Set UserRange = oExcel.Worksheets(imya_lista).Range("A3:I" & lLastRow) 'oExcel.InputBox _
    '(Prompt:="�������� �������� A3:Ix", _
    'Title:="����� ���������", _
    'Type:=8)
    Set Total = UserRange
        For Each tr In Total.Rows
            rc = rc + 1
            sc = 0
            For Each tc In Total.Rows.Columns
                sc = sc + 1
            Next tc
        Next tr
    ReDim arr(rc, sc) As Variant
    For qx = 1 To rc
        For qy = 1 To sc
            arr(qx, qy) = Total.Cells(qx, qy) ' ���������� ������� arr
        Next qy
    Next qx
    sp.Close SaveChanges:=False
    oExcel.Application.Quit
    

End Sub

Private Sub fill_table(bEvents As Boolean)  ' ���������� ������������
    'Application.ScreenUpdating = 1
    Dim vys_yach As Double
    Dim vys_str As Double
    Dim mmm As Integer
    Dim DocCell As Cell
    Dim FTx As Integer
    Dim FTy As Integer
    pNumber = 1
    Set DocCell = ActiveDocument.DocumentSheet.Cells("user.coc")
    DocCell.FormulaU = 1
    Dim pec As Integer ' ������� ���������� ����� ������������ �� ��������
    pec = 1
    Dim mast As Master
    Dim pg As Page
    Dim aPage As Visio.Page
    Dim pName As String
    pName = "�"
    Set aPage = AddNamedPage("�")
    ActivePage.PageSheet.Cells("PageWidth").Formula = "420 MM"
    ActivePage.PageSheet.Cells("PageHeight").Formula = "297 MM"
    ActivePage.PageSheet.Cells("Paperkind").Formula = 8
    ActivePage.PageSheet.Cells("PrintPageOrientation").Formula = 2

    ActivePage.Shapes.ItemFromID(1).Cells("prop.type").Formula = """������������ ������������, ������� � ����������"""
    Set pg = ActivePage
    Set mast = Application.Documents.Item("SAPR_ASU_SHAPE.vss").Masters.Item("������������") 'ActiveDocument.Masters.Item("������������")
    pg.Drop mast, 6.889764, 8.661417
    
    Dim target As Shape ' ������� ����
    Dim main As Shape   ' ���� - �������� ������
    ' Dim rw As Shape     ' ���� - ������
    Dim rn As String      ' ��� �����-������

    
    Set main = ActivePage.Shapes.Item("������������")
    'ActivePage.Shapes.ItemFromID(1).Cells("Prop.tnum").Formula = "=thedoc!user.coc"
    Dim SSS As Shapes  ' ������������ ������ �������� ������
    Dim tn As String ' ��� �������� �����
    Set SSS = main.Shapes
    For FTy = 1 To rc
        rn = "row" & pec
        Set rw = SSS.Item(rn)
        For FTx = 1 To sc
            tn = pec & "." & FTx
            Set target = rw.Shapes.Item(tn)
            If FTx = 2 Or FTx = 9 Then target.CellsSRC(visSectionParagraph, 0, visHorzAlign).FormulaU = "0"
            target.Text = arr(FTy, FTx)
        Next FTx
        If bEvents Then
            DoEvents
        End If
        'Dim mas(1 To 1000) As Double
        'mas(FTy) = rw.Cells("Height").ResultIU
        
'        vys_str = vys_str + rw.Cells("Height").ResultIU
'
'
'        If vys_str = main.Cells("User.V.Prompt").Result("") Then
'            mmm = 1
'        ElseIf vys_str > main.Cells("User.V.Prompt").Result("") Then
'            mmm = 2
'        End If
        
        
        
        
        'If mmm = 2 Then
        If main.CellsSRC(visSectionUser, 7, visUserValue) = 2 Then

            While main.Cells("User.V").Result("") > main.Cells("User.V.Prompt").Result("")
                'Dim Time As Date
                'Time = Now() + TimeValue("0:0:3")
                'While Now() < Time
                'Wend
                
                For xx = 1 To sc
                    tn = pec & "." & xx
                    Set target = rw.Shapes.Item(tn)
                    target.Text = " "
                    target.CellsSRC(visSectionObject, visRowXFormOut, visXFormHeight).FormulaU = "0 mm"
                Next xx
                FTy = FTy - 1
                pec = pec - 1
                rn = "row" & pec
                Set rw = SSS.Item(rn)

'                If kostyl Then
'                    xx = MsgBox("������� ������ ������: " & (vys_str * 25.4) & " �� /  " & (main.Cells("User.V.Prompt").Result("") * 25.4) & " max" & vbCrLf & vbCrLf & "���� �� �������, ShapeSheet �������� ������������� �� Visio 2007", vbYesNo, "��� ��-������ ���")
'                End If
            Wend
            pec = 0
            pNumber = pNumber + 1
            DocCell.Formula = pNumber
            Set aPage = AddNamedPage("�." & pNumber)
            ActivePage.PageSheet.Cells("PageWidth").Formula = "420 MM"
            ActivePage.PageSheet.Cells("PageHeight").Formula = "297 MM"
            ActivePage.PageSheet.Cells("Paperkind").Formula = 8
            ActivePage.PageSheet.Cells("PrintPageOrientation").Formula = 2
            'ActivePage.Shapes(1).Cells("Prop.cnum.value") = pNumber
            ActivePage.Shapes.ItemFromID(1).Cells("prop.chapter.value").Formula = """�-������������ ������������, ������� � ����������"""
            'ActivePage.Shapes(1).Cells("fields.value").FormulaU = "=pagenumber()" & "-1"
            ActivePage.Drop mast, 6.889764, 8.661417
            Set main = ActivePage.Shapes.Item("������������")
            Set SSS = main.Shapes
            If pNumber = 1 Then
                'ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
                ActivePage.Shapes(1).Cells("user.n.value") = 3
                'ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
            Else
                'ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
                ActivePage.Shapes(1).Cells("user.n.value") = 6
                'ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
            End If
            
            
            'mmm = 0
            'vys_str = 0
        End If
        
        
        'If mmm = 1 And FTy <> rc Then
        If main.CellsSRC(visSectionUser, 7, visUserValue) = 1 And FTy <> rc Then ' ��� ����� !!!
            
            pec = 0
            pNumber = pNumber + 1
            DocCell.Formula = pNumber
            Set aPage = AddNamedPage("�." & pNumber)
            ActivePage.PageSheet.Cells("PageWidth").Formula = "420 MM"
            ActivePage.PageSheet.Cells("PageHeight").Formula = "297 MM"
            ActivePage.PageSheet.Cells("Paperkind").Formula = 8
            ActivePage.PageSheet.Cells("PrintPageOrientation").Formula = 2
            'ActivePage.Shapes(1).Cells("Prop.cnum.value") = pNumber
            ActivePage.Shapes.ItemFromID(1).Cells("prop.chapter.value").Formula = """�-������������ ������������, ������� � ����������"""
            'ActivePage.Shapes(1).Cells("fields.value").FormulaU = "=pagenumber()" & "-1"
            ActivePage.Drop mast, 6.889764, 8.661417
            Set main = ActivePage.Shapes.Item("������������")
            Set SSS = main.Shapes
            If pNumber = 1 Then
                'ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
                ActivePage.Shapes(1).Cells("user.n.value") = 3
                'ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
            Else
                'ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
                ActivePage.Shapes(1).Cells("user.n.value") = 6
                'ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
            End If
            
            'mmm = 0
            'vys_str = 0
        End If
        
        pec = pec + 1
        If pec > 30 Then pec = 0
        
        
        
    Next FTy
    'If pNumber = 6 Then MsgBox "Attention"
    pNumber = 1
    rc = 0
 End Sub
 
Function AddNamedPage(pName As String) As Visio.Page
    Dim aPage As Visio.Page
    Dim Ramka As Visio.Master
    Set aPage = ActiveDocument.Pages.Add
    aPage.Name = pName
    
    Set Ramka = Application.Documents.Item("SAPR_ASU_SHAPE.vss").Masters.Item("�����")  'ActiveDocument.Masters.Item("�����")
    Set sh = ActivePage.Drop(Ramka, 0, 0)
    'ActivePage.Shapes(1).Cells("fields.value").FormulaU = "=TheDoc!User.dec & "".CO"""
    '������ ������� "=pagenumber()-thedoc!user.coc"
    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("shifr").Cells("fields.value").FormulaU = "=TheDoc!User.dec & "".CO"""
    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("list").Cells("fields.value").FormulaU = "=PAGENUMBER()+Sheet.1!Prop.CNUM + TheDoc!User.coc - PAGECOUNT()"
    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("listov").Cells("fields.value").FormulaU = "=TheDoc!User.coc"
    ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
    ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
    
    Set AddNamedPage = aPage
End Function

Private Sub del_sp()
'    Dim opn As Long
'    Dim con As Long
'    Dim pName As String
'    Dim pa As Page
'    Dim dp As Page
'    Dim CO As Shape
'    Dim cx As Integer
'    Dim dn As String
'    pName = "�"
'    con = ActiveDocument.DocumentSheet.Cells("user.coc")
'    opn = ActiveDocument.Pages.Item(pName).Index
'    For cx = con To 2 Step -1
'        dn = "�." & cx
'        Set pa = ActiveDocument.Pages.Item(dn)
'        pa.Delete (1)
'    Next cx
'   On Error Resume Next
'   Set CO = ActiveDocument.Pages.Item("�").Shapes.Item("������������")
'   CO.Delete
    Dim dp As Page
    Dim colPage As Collection
    Set colPage = New Collection
    '�������� ��� �������� � ��������� � ��������� ���� ������ (���� ������� ����� ��� ��, �� 3-� �������� ���������� 2-�, � 2-� for each ��� ��������� :) ������ )
    For Each dp In ActiveDocument.Pages
        If InStr(1, dp.Name, "�.") > 0 Then
            colPage.Add dp
        End If
    Next
    '������� ��� �������� ������� ����� ����
    For Each dp In colPage
        dp.Delete (1)
    Next
    On Error Resume Next
    ActiveDocument.Pages.Item("�").Delete (1)
    ActiveDocument.DocumentSheet.Cells("user.coc").Formula = 0
End Sub

Public Sub spEXP_2_XLS()
    Dim opn As Long
    Dim npName As String
    Dim pName As String
    Dim np As Page
    Dim pg As Page
    Dim n As Integer
    pName = "�"
    str = 1
    opn = ActiveDocument.Pages.Item(pName).Index
    Application.ActiveWindow.Page = ActiveDocument.Pages.Item("�")
    get_data
    For n = 2 To ActiveDocument.DocumentSheet.Cells("user.coc")
        pName = "�." & n
        Application.ActiveWindow.Page = ActiveDocument.Pages.Item(pName)
        get_data
    Next
    Dim apx As Excel.Application
    Set apx = CreateObject("Excel.Application")
    Dim wb As Excel.Workbook
    Dim sht As Excel.Sheets
    Dim en As String
    Dim un As String
    
    Dim sPath, sFile As String
    sPath = Visio.ActiveDocument.Path
    sFileName = "SP_2_Visio.xls"
    sFile = sPath & sFileName
    
    
    If Dir(sFile, 16) = "" Then '���� ���� �� ���� ����
        MsgBox "���� " & sFileName & " �� ������ � �����: " & sPath, vbCritical, "������"
        Exit Sub
    End If
    
    Set wb = apx.Workbooks.Open(sFile)
    

    
    'Set wb = apx.Workbooks.Add
    'un = Format(Now(), "yyyy_mm_dd")
    'pth = Visio.ActiveDocument.Path
    'en = pth & "������������_" & un & ".xls"
    apx.Visible = True
    '������� ������ ����
    apx.DisplayAlerts = False
    On Error Resume Next
    apx.Sheets("EXP_2_XLS").Delete
    apx.DisplayAlerts = True
    '��������� �����
    apx.Sheets("SP").Copy After:=apx.Sheets(apx.Worksheets.Count)
    apx.Sheets("SP (2)").Name = "EXP_2_XLS"
    
    
    lLastRow = apx.Sheets("EXP_2_XLS").Cells(apx.Rows.Count, 1).End(xlUp).Row
    apx.Application.CutCopyMode = False
    apx.Worksheets("EXP_2_XLS").Activate
    apx.ActiveSheet.Rows("6:" & lLastRow).Delete Shift:=xlUp
    apx.ActiveSheet.Range("A3:I5").ClearContents
    apx.ActiveSheet.Rows("5:" & str).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
    
    wb.Activate
        
        For xx = 1 To str + 2
            For yx = 1 To 9
                wb.Sheets("EXP_2_XLS").Cells(xx + 2, yx) = tabl(xx, yx)
                'wb.Sheets("EXP_2_XLS").Range("A" & (xx + 2)).Select '��� �����������
            Next yx
        Next xx
        
    apx.ActiveSheet.Range("A3:I" & apx.Sheets("EXP_2_XLS").Cells(apx.Rows.Count, 1).End(xlUp).Row).WrapText = False
    apx.ActiveSheet.Range("A3:I" & apx.Sheets("EXP_2_XLS").Cells(apx.Rows.Count, 1).End(xlUp).Row).RowHeight = 20 '���� ������, � ������� ���� ������������� ������, ���� ��������� �� ������, �� �� �� �������� � ���������� ��� ����� ������������
   

    wb.Close SaveChanges:=True
    apx.Quit
    MsgBox "������������ �������������� � ���� SP_2_Visio.xls �� ���� EXP_2_XLS", vbInformation
End Sub

Function get_data() '(pgName As Page)
    Dim r As Integer
    Dim target As Shape
    Dim c As Integer
    Dim main As Shape   ' ���� - �������� ������
    Dim rw As Shape     ' ���� - ������
    Dim rn As String      ' ��� �����-������
    Set main = ActivePage.Shapes.Item("������������")
    Dim SSS As Shapes  ' ������������ ������ �������� ������
    Dim tn As String ' ��� �������� �����
    Set SSS = main.Shapes
    For r = 1 To 30
        rn = "row" & r
        Set rw = SSS.Item(rn)
        If rw.CellsSRC(visSectionObject, visRowXFormOut, visXFormHeight) = 0 Then GoTo out:
        For c = 1 To 9
            tn = r & "." & c
            Set target = rw.Shapes.Item(tn)
            tabl(str, c) = target.Text
        Next c
        str = str + 1
    Next r
out:
End Function






