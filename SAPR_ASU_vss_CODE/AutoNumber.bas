Attribute VB_Name = "AutoNumber"
'------------------------------------------------------------------------------------------------------------
' Module        : AutoNumber - �������������
' Author        : gtfox
' Date          : 2020.05.11
' Description   : �������������/������������� ��������� �����
' Link          : https://visio.getbb.ru/viewtopic.php?f=44&t=1491, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------







'Sub AutoNumEvent(vsoShapeEvent As Shape)
''------------------------------------------------------------------------------------------------------------
'' Macros        : AutoNumEvent - ������������� ��� ��������� �������
'                '����� ���������� ������� ����������� �������� � �������
'                '� EventDrop ������ ���� ������� =CALLTHIS("ThisDocument.AutoNumEvent")
'                '���� ������ ���������� � ThisDocument
''------------------------------------------------------------------------------------------------------------
'    Set vsoWindowEvent = ActiveWindow
'    Set vsoShapePaste = vsoShapeEvent
'    Click = False
'    AutoNum vsoShapePaste
'End Sub

Public Sub AutoNum(vsoShape As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : AutoNum - ������������� ��������� ��� ������/�����������
                '��������� ������ ������������ � ������������� �������� ��������� ������������ ���������
                '����, � ������ ����� ��� ������ �������, ��� ����� ������ �� ��������
                '��� ������� ��� � ��������� ����������� ������������� ��������� ReNumber()
                
                '����� ���������� �������� ������� �� ����������� �������� � �������
                '� EventMultiDrop ������ ���� ������� = CALLTHIS("AutoNumber.AutoNum", "SAPR_ASU")
'------------------------------------------------------------------------------------------------------------

    Dim SymName As String       '��������� ����� ���������
    Dim NomerShemy As Integer   '��������� ��������� ���� � �������� ����� ����� (������ ������ �����)
    Dim UserType As Integer     '��� �������� �����: ������, ������, ����
    Dim LastNumber As Integer   '������������ �������� ��������� ������������ ���������. ��� �� ����� ����� ���������, � ���� ����� � �����������.

'    Dim TheDoc As Visio.Shape
'    Set TheDoc = Application.ActiveDocument.DocumentSheet
    
    Dim ThePage As Visio.Shape
    Set ThePage = ActivePage.PageSheet
    
    Dim vsoShapeOnPage As Visio.Shape

    Dim vsoPage As Visio.Page
    Dim PageName As String
    PageName = "�����"  '����� ������ ��� �������� ���������
    If ThePage.CellExists("Prop.NomerShemy", 0) Then NomerShemy = ThePage.Cells("Prop.NomerShemy").Result(0)    '����� �����. ���� ���� ����� �� ���� ������, �� �� ���� ������ ������ ���� ���� �����. �� ��������� = 1
    
    '������ ��� � ��������� ����������� ��������, ������� �������� �� �����
    If vsoShape.CellExists("User.Type", 0) Then UserType = vsoShape.Cells("User.Type").Result(0)
    If vsoShape.CellExists("Prop.SymName", 0) Then SymName = vsoShape.Cells("Prop.SymName").ResultStr(0)

    '���� ������ ������������� ������ ������������ ��������� �����
    For Each vsoPage In ActiveDocument.Pages    '���������� ��� ����� � �������� ���������
        If InStr(1, vsoPage.Name, PageName) > 0 Then    '����� ��, ��� �������� "�����" � �����
            If vsoPage.PageSheet.Cells("Prop.NomerShemy").Result(0) = NomerShemy Then    '����� ��� ����� � ������� ���, �� ������� ��������� �������
                For Each vsoShapeOnPage In vsoPage.Shapes    '���������� ��� ����� � ��������� ������
                    If vsoShapeOnPage.CellExists("User.Type", 0) Then   '���� � ����� ���� ���, �� -
                        If vsoShapeOnPage.Cells("User.Type").Result(0) = UserType Then    '- ��������� ����� �������� � ����� (������� ��������)
                            If (vsoShapeOnPage.Cells("Prop.SymName").ResultStr(0) = SymName) And (vsoShapeOnPage.NameID <> vsoShape.NameID) Then '����� ��������� � ��� �� ��� �� ���� ������� ��������
                                If vsoShapeOnPage.Cells("Prop.AutoNum").Result(0) = 1 Then    '��������� ����� ���������� �������
                                    Select Case UserType
                                        Case 3 '������
                                            If vsoShapeOnPage.Cells("Prop.NumberKlemmnik").Result(0) = vsoShape.Cells("Prop.NumberKlemmnik").Result(0) Then '�������� ������ �� ������ ���������
                                                If vsoShapeOnPage.Cells("Prop.Number").Result(0) > LastNumber Then    '���� ������������ �������� ������ ��������
                                                    LastNumber = vsoShapeOnPage.Cells("Prop.Number").Result(0)    '����������. � �� ��� ������ ���� �� �������
                                                End If
                                            End If
                                        Case Else '��������� ��������
                                            If vsoShapeOnPage.Cells("Prop.Number").Result(0) > LastNumber Then    '���� ������������ �������� ������ ��������
                                                LastNumber = vsoShapeOnPage.Cells("Prop.Number").Result(0)    '����������. � �� ��� ������ ���� �� �������
                                            End If
                                    End Select
                                End If
                            End If
                        End If
                    End If
                Next
            End If
        End If
    Next

    '�� ����������� ������� ������� ������������ ��������� ����� + 1
    vsoShape.Cells("Prop.Number").FormulaU = LastNumber + 1
    
    '���� ��� ���� �� ������ ������ ������
    If vsoShape.Cells("User.Type").Result(0) = typeCoil Then
        For i = 1 To vsoShape.Section(visSectionScratch).Count
            '������ ����
            vsoShape.CellsU("Scratch.A" & i).FormulaU = """""" '����� � ShapeSheet ������ �������. ���� �������� ������ ������, �� ����� NoFormula � ��������� ��������� ���������
            vsoShape.CellsU("Scratch.C" & i).FormulaU = ""
            vsoShape.CellsU("Scratch.D" & i).FormulaU = ""
        Next
    End If
    
    '��������� �������. ��� ���� ������������������� xD
    Set ActivePages = ActiveDocument.Pages
    
End Sub



Public Sub ReNumber()
'------------------------------------------------------------------------------------------------------------
' Macros        : ReNumber - ������������� ���������

                '������������� ���������� ����� �������, ������ ����
                '���������� �� ������� ��������� ��������� �� �����
                '� ���������� �� �� ������� �� �������������.
                '���� � �������� Prop.AutoNum=0 �� �� �� ��������� � �������������
                '������������� ��������� ���� � �������� ����� ����� (������ ������ �����)
'------------------------------------------------------------------------------------------------------------
    Dim shpElement As Shape
    Dim Prev As Shape
    Dim shp�ol As Collection
    Set shp�ol = New Collection
    Dim shpMas() As Shape
    Dim shpTemp As Shape
    Dim ss As String
    Dim i As Integer, ii As Integer, j As Integer, n As Integer
    
    '�������� � ��������� ������ ��� ���������� �����
    For Each shpElement In ActivePage.Shapes
        If shpElement.CellExists("User.Type", False) Then
            If shpElement.Cells("User.Type").Result(0) = typeCoil Then
                shp�ol.Add shpElement
                'Debug.Print shpElement.Cells("PinX").Result("mm") & " - " & shpElement.Cells("PinY").Result("mm")
            End If
        End If
    Next
    
    '�� ��������� �������� �� � ������ ��� ����������
    ReDim shpMas(shp�ol.Count - 1)
    i = 0
    For Each shpElement In shp�ol
        Set shpMas(i) = shpElement
        i = i + 1
    Next

    ' "���������� ���������" ������� ����� �� ����������� ���������� �
    UbMas = UBound(shpMas)
    For j = 1 To UbMas
        Set shpTemp = shpMas(j)
        i = j
        While shpMas(i - 1).Cells("PinX").Result("mm") > shpTemp.Cells("PinX").Result("mm") '>:�����������, <:��������
            Set shpMas(i) = shpMas(i - 1)
            i = i - 1
            If i <= 0 Then GoTo ExitWhileX
        Wend
ExitWhileX:  Set shpMas(i) = shpTemp
    Next

'    Debug.Print "---"
'    For i = 0 To UbMas
'        Debug.Print shpMas(i).Cells("PinX").Result("mm") & " - " & shpMas(i).Cells("PinY").Result("mm")
'    Next
    
    '������� ����� � ���������� ����������� � � ��������� Y-��
    'Debug.Print "---"
    Group = False
    Set shp�ol = New Collection
    For ii = 1 To UbMas
        If (Abs(shpMas(ii - 1).Cells("PinX").Result("mm") - shpMas(ii).Cells("PinX").Result("mm")) < 0.5) And (ii < UbMas) Then
            'shp�ol.Add shpMas(i)
            If Group = False Then
                StartIndex = ii - 1 '�� ������ �������� ���������� ��� �����
                Group = True    '������ �������� �������� ����������
            End If
            'Debug.Print shpMas(i).Cells("PinX").Result("mm") & " - " & shpMas(i).Cells("PinY").Result("mm")
        ElseIf Group Then
            'shp�ol.Add shpMas(i)
            Group = False   '������� ������ �� ����������. ���������.
            EndIndex = ii - 1
            If (ii = UbMas) And (Abs(shpMas(ii - 1).Cells("PinX").Result("mm") - shpMas(ii).Cells("PinX").Result("mm")) < 0.5) Then EndIndex = ii '���� ��������� �������, �� �������� ��� � ����������
           'Debug.Print shpMas(i).Cells("PinX").Result("mm") & " - " & shpMas(i).Cells("PinY").Result("mm")

            '--V--��������� �� �������� ���������� Y
            For j = StartIndex + 1 To EndIndex
                Set shpTemp = shpMas(j)
                i = j
                While shpMas(i - 1).Cells("PinY").Result("mm") < shpTemp.Cells("PinY").Result("mm") '>:�����������, <:��������
                    Set shpMas(i) = shpMas(i - 1)
                    i = i - 1
                    If i <= StartIndex Then GoTo ExitWhileY
                Wend
ExitWhileY:     Set shpMas(i) = shpTemp
            Next
            '--�--���������� �� �������� ���������� Y
        End If
    Next
    Set shp�ol = Nothing
    
    '���������������� ��������������� ������
    For i = 0 To UbMas
        shpMas(i).Text = "KL" & (i + 1)
    Next

'    Debug.Print "---"
'    For i = 0 To UbMas
'        Debug.Print shpMas(i).Cells("PinX").Result("mm") & " - " & shpMas(i).Cells("PinY").Result("mm")
'    Next

    '��������� �������. ��� ���� ������������������� xD
    Set ActivePages = ActiveDocument.Pages
    
End Sub


Private Sub NomerShemyAdd()

    Dim ThePage As Visio.Shape


    Dim vsoPage As Visio.Page
    Dim PageName As String
    PageName = "�����"
    
    For Each vsoPage In ActiveDocument.Pages
        If InStr(1, vsoPage.Name, PageName) > 0 Then
            Set ThePage = vsoPage.PageSheet
            If Not ThePage.CellExists("Prop.NomerShemy", 0) Then
                'Prop
                ThePage.AddRow visSectionProp, visRowLast, visTagDefault
                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsValue).RowNameU = "NomerShemy"
                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsLabel).FormulaForceU = """����� �����"""
                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsPrompt).FormulaForceU = """��������� ��������� ���� � �������� ����� �����"""
                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsType).FormulaForceU = "2"
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsFormat).FormulaForceU = """"""
                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsValue).FormulaForceU = "1"
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsSortKey).FormulaForceU = """"""
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsInvis).FormulaForceU = "FALSE"
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsAsk).FormulaForceU = "FALSE"
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsLangID).FormulaForceU = "1033"
'                ThePage.CellsSRC(visSectionProp, visRowLast, visCustPropsCalendar).FormulaForceU = "0"
            
'-------------------------------------------------------------------------------------------------------------
                'User
'                ThePage.AddRow visSectionUser, visRowLast, visTagDefault
'                ThePage.CellsSRC(visSectionUser, visRowLast, visUserValue).RowNameU = "QF"
'                ThePage.CellsSRC(visSectionUser, visRowLast, visUserValue).FormulaU = 88
'                ThePage.CellsSRC(visSectionUser, visRowLast, visUserPrompt).FormulaU = """qqq"""
            End If
        End If
    Next

End Sub



''' ������ �������� ������ � ������ user-defined ��������� '''
Public Sub EditListValue(nameCell As String, numValue As Integer, newValue)
' 1 �������� - ��� ������ ��� ���������
' 2 �������� - ����� �������� ��� ������ � ������ �������� (������� � 1)
' 3 �������� - ����� �������� ��� ������
Dim arrList
Dim docSheet As Visio.Shape
Dim visDoc As Visio.Document
Set visDoc = Application.ActiveDocument
Set docSheet = visDoc.DocumentSheet

With docSheet.Cells(nameCell)
     arrList = Split(.FormulaU, ";")  ' ������� ������ �������� �� �������
     arrList(numValue - 1) = newValue ' ������ ���� �� ��������
     .FormulaU = Join(arrList, ";")   ' ������� ������ �� �������� ������� � ���������� ����� � ������
End With

End Sub

''' ������ �������� ������ �� ������ user-defined ��������� '''
Public Function ReadListValue(nameCell As String, numValue As Integer)
' 1 �������� - ��� ������ ��� ������
' 2 �������� - ����� �������� ��� ������ � ������ �������� (������� � 1)
Dim arrList
Dim docSheet As Visio.Shape
Dim visDoc As Visio.Document
Set visDoc = Application.ActiveDocument
Set docSheet = visDoc.DocumentSheet

With docSheet.Cells(nameCell)
    arrList = Split(.FormulaU, ";")       ' ������� ������ �������� �� �������
    ReadListValue = arrList(numValue - 1) ' ��������� ��������
End With

End Function

Function ExtractOboz(Oboz) ' ������� ����������� ������������ ����� �����������

Dim ObozF As String, i As Integer, Flag As Boolean
Flag = Oboz Like "*[-.,/\]*"

For i = 1 To Len(Oboz)
    If Not Flag And Mid(Oboz, i, 1) Like "[a-zA-Z�-��-� ]" Then GoSub AddChar
    If Flag And Mid(Oboz, i, 1) Like "[a-zA-Z�-��-�0-9 ]" Then GoSub AddChar
    If Flag And Mid(Oboz, i, 1) Like "[-.,/\]" Then GoSub AddChar
Next
    
ExtractOboz = ObozF
Exit Function

AddChar:
    ObozF = ObozF + Mid(Oboz, i, 1)
Return
End Function ' ***************************** AutoNum *************************


