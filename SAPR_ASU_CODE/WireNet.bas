'------------------------------------------------------------------------------------------------------------
' Module        : WireNet - Провода на схеме электрической принципиальной
' Author        : gtfox
' Date          : 2020.06.03
' Description   : Соединение/отсоединение проводов, нумерация, удаление, стрелки/точки на концах, взаимодействие с элементами
' Link          : https://visio.getbb.ru/viewtopic.php?f=44&t=1491, https://github.com/gtfox/SAPR_ASU, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------
Option Explicit
Public bUnGlue As Boolean 'Запрет обработки события ConnectionsDeleted


Sub ConnectWire(Connects As IVConnects)
'------------------------------------------------------------------------------------------------------------
' Macros        : ConnectWire - Цепляет провод к проводу или элементу
                'В зависимости от того к чему цепляем: провод, разрыв провода или элемент, производим заполнение
                'полей имени, номера, источника номера. Для проводов ставим точку на конце, для элементов - убираем красную стрелку
                'Макрос вызывается событием ConnectionsAdded
'------------------------------------------------------------------------------------------------------------
    Dim shpProvod As Visio.Shape
    Dim shpSource As Visio.Shape
    Dim ShapeNaDrugomKonce As Visio.Shape
    Dim RefNashegoProvoda As String, AdrNashegoProvoda As String, GUIDNashegoProvoda As String, RefSource As String, AdrSource As String, GUIDSource As String, kogo As String, kem As String
    Dim i As Integer, ii As Integer
    Dim ShapeType As Integer
    Dim ShapeTypeNaDrugomKonce As Integer
    
    ShapeType = ShapeSAType(Connects.ToSheet) 'Тип шейпа, к которому подсоединили провод
    
    Select Case ShapeType
    
        Case typeCxemaNO, typeCxemaNC, typeCxemaCoil, typeCxemaParent, typeCxemaElement, typePLCTerm, typeCxemaWireLinkS, typeCxemaWireLinkR, typeCxemaTerm, typeCxemaWire, typeCxemaSensorTerm
    
            Set shpProvod = Connects.FromSheet
            
            If Connects.ToSheet.CellExists("User.Shkaf", 0) Then
                Set shpSource = Connects.ToSheet
            Else
                Set shpSource = FindParentOfTerm(Connects.ToSheet)
            End If
                        

            RefSource = "Pages[" & shpSource.ContainingPage.NameU & "]!" & shpSource.NameID 'Адрес источника нумерации (к которому подключаемся)
            RefNashegoProvoda = "Pages[" & shpProvod.ContainingPage.NameU & "]!" & shpProvod.NameID 'Адрес нашего (подключаемого) провода
            AdrSource = shpSource.ContainingPage.NameU & "/" & shpSource.NameID
            GUIDSource = shpSource.UniqueID(visGetOrMakeGUID)
            AdrNashegoProvoda = shpProvod.ContainingPage.NameU & "/" & shpProvod.NameID
            GUIDNashegoProvoda = shpProvod.UniqueID(visGetOrMakeGUID)
            
            
            Select Case shpProvod.Connects.Count 'кол-во соединенных концов у провода
            
                Case 1 'С одной стороны
                
                    'Если шейп, к которому подсоединили провод - оказался тоже провод или конечный разрыв провода (дочерний)
                    If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkR) Then
        
                        shpProvod.Cells("Prop.Number").FormulaU = RefSource & "!Prop.Number" 'Получаем номер от существующего провода (к которому подсоединились)
                        shpProvod.Cells("Prop.SymName").FormulaU = RefSource & "!Prop.SymName" 'Получаем имя от существующего провода (к которому подсоединились)
                        shpProvod.Cells("User.Shkaf").FormulaU = RefSource & "!User.Shkaf"
                        shpProvod.Cells("User.Mesto").FormulaU = RefSource & "!User.Mesto"
                        shpProvod.Cells("Prop.AutoNum").FormulaU = False 'Убираем автонумерацию (т.к. номер получаем по ссылке от другого провода)
                        If ShapeType = typeCxemaWire Then
                            SetArrow 10, Connects(1) 'Ставим точку если это провод а не разрыв
                        ElseIf ShapeType = typeCxemaWireLinkR Then
                            SetArrow 0, Connects(1) 'Убираем стрелку
                        End If
                        shpProvod.Cells("User.AdrSource").FormulaU = Chr(34) & AdrSource & Chr(34) 'Сохраняем адрес источника номера
                        shpProvod.Cells("User.AdrSource.Prompt").FormulaU = GUIDSource
                        'shpProvod.Cells("Prop.HideNumber").FormulaU = True 'Скрываем номер (возможно)
                        'shpProvod.Cells("Prop.HideName").FormulaU = True 'Скрываем название (возможно)
                    Else
                    'Если шейп, к которому подсоединили провод - оказался НЕ провод... (элемент)
                        SetArrow 0, Connects(1) 'Убираем стрелку
                        
                        'Пишем номер провода в родительский ПЛК
                        If ShapeType = typePLCTerm Then
                            WireToPLCTerm shpProvod, Connects.ToSheet, True
                        End If

                        shpProvod.Cells("User.Shkaf").FormulaU = RefSource & "!User.Shkaf"
                        shpProvod.Cells("User.Mesto").FormulaU = RefSource & "!User.Mesto"
                        
                        'Если это начальный разрыв провода (родительский) - присваиваем ему имя и номер провода
                        If ShapeType = typeCxemaWireLinkS Then
                            Connects.ToSheet.Cells("Prop.Number").FormulaU = RefNashegoProvoda & "!Prop.Number" 'Записываем номер нашего провода
                            Connects.ToSheet.Cells("Prop.SymName").FormulaU = RefNashegoProvoda & "!Prop.SymName" 'Записываем имя нашего провода
                            Connects.ToSheet.Cells("User.AdrSource").FormulaU = Chr(34) & AdrNashegoProvoda & Chr(34) 'Сохраняем адрес источника номера
                            Connects.ToSheet.Cells("User.AdrSource.Prompt").FormulaU = GUIDNashegoProvoda
                            Connects.ToSheet.Cells("User.Shkaf").FormulaU = RefNashegoProvoda & "!User.Shkaf"
                            Connects.ToSheet.Cells("User.Mesto").FormulaU = RefNashegoProvoda & "!User.Mesto"
                        End If
                    End If
                    
                Case 2 'С двух сторон
                
                    'Находим тип шейпа, на друм конце нашего провода
                    For i = 1 To shpProvod.Connects.Count 'смотрим все соединения (их 2 :) )
                        If shpProvod.Connects(i).FromPart <> Connects(1).FromPart Then 'Отбрасывам то, которое только что произошло (берем другой конец)
                            ShapeTypeNaDrugomKonce = ShapeSAType(shpProvod.Connects(i).ToSheet) 'Тип шейпа, на друм конце нашего провода
                            Set ShapeNaDrugomKonce = shpProvod.Connects(i).ToSheet
                        End If
                    Next
                    
                    'Если шейп, к которому подсоединили провод - оказался тоже провод или конечный разрыв провода (дочерний)
                    If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkR) Then
                    
                        If ShapeType = typeCxemaWire Then
                            SetArrow 10, Connects(1) 'Ставим точку если это провод а не разрыв
                        ElseIf ShapeType = typeCxemaWireLinkR Then
                            SetArrow 0, Connects(1) 'Убираем стрелку
                        End If
                        
                        'если другой конец подсоединен НЕ к проводу - получаем номер от провода к которому подсоединились
                        If (ShapeTypeNaDrugomKonce <> typeCxemaWire) And (ShapeTypeNaDrugomKonce <> typeCxemaWireLinkR) Then 'Смотрим что на другом конце НЕ провод и НЕ конечный разрыв провода (дочерний)
                       
                            shpProvod.Cells("Prop.Number").FormulaU = RefSource & "!Prop.Number" 'Получаем номер от существующего провода (к которому подсоединились)
                            shpProvod.Cells("Prop.SymName").FormulaU = RefSource & "!Prop.SymName" 'Получаем имя от существующего провода (к которому подсоединились)
                            shpProvod.Cells("Prop.AutoNum").FormulaU = False 'Убираем автонумерацию (т.к. номер получаем по ссылке от другого провода)
                            shpProvod.Cells("User.AdrSource").FormulaU = Chr(34) & AdrSource & Chr(34) 'Сохраняем адрес источника номера
                            shpProvod.Cells("User.AdrSource.Prompt").FormulaU = GUIDSource
                            shpProvod.Cells("User.Shkaf").FormulaU = RefSource & "!User.Shkaf"
                            shpProvod.Cells("User.Mesto").FormulaU = RefSource & "!User.Mesto"
        '                    shpProvod.Cells("Prop.HideNumber").FormulaU = True 'Скрываем номер (возможно)
        '                    shpProvod.Cells("Prop.HideName").FormulaU = True 'Скрываем название (возможно)
                        Else
                            'если другой конец подсоединен к проводу, и номер получен по ссылке от нас - получаем номер от провода к которому подсоединились
                            If ShapeNaDrugomKonce.Cells("Prop.Number").Formula Like shpProvod.NameU & "!*" Then
                                shpProvod.Cells("Prop.Number").FormulaU = RefSource & "!Prop.Number" 'Получаем номер от существующего провода (к которому подсоединились)
                                shpProvod.Cells("Prop.SymName").FormulaU = RefSource & "!Prop.SymName" 'Получаем имя от существующего провода (к которому подсоединились)
                                shpProvod.Cells("Prop.AutoNum").FormulaU = False 'Убираем автонумерацию (т.к. номер получаем по ссылке от другого провода)
                                shpProvod.Cells("User.AdrSource").FormulaU = Chr(34) & AdrSource & Chr(34) 'Сохраняем адрес источника номера
                                shpProvod.Cells("User.AdrSource.Prompt").FormulaU = GUIDSource
                                shpProvod.Cells("User.Shkaf").FormulaU = RefSource & "!User.Shkaf"
                                shpProvod.Cells("User.Mesto").FormulaU = RefSource & "!User.Mesto"
            '                    shpProvod.Cells("Prop.HideNumber").FormulaU = True 'Скрываем номер (возможно)
            '                    shpProvod.Cells("Prop.HideName").FormulaU = True 'Скрываем название (возможно)
                            Else
                                'если другой конец подсоединен к проводу - то проводу, к которому подсоединились, присваиваем номер от нашего присоединенного провода
                                kogo = Connects.ToSheet.Cells("Prop.Number").Result(0) & ": " & Connects.ToSheet.Cells("Prop.SymName").ResultStr(0)
                                kem = shpProvod.Cells("Prop.Number").Result(0) & ": " & shpProvod.Cells("Prop.SymName").ResultStr(0)
            
                                If MsgBox("Перезаписать провод" & vbCrLf & vbCrLf & kem & " -> " & kogo, vbOKCancel + vbExclamation, "САПР-АСУ: Перезапись провода") = vbOK Then
                                
                                    If ShapeType = typeCxemaWireLinkR Then 'Нельзя перезаписать "приемник разрыва провода" (дочерний), т.к. номер ему присвоен от "источника разрыва провода" (родителя)
                                    
                                        MsgBox "Нельзя перезаписать ""Приемник разрыва провода"" (дочерний), т.к. номер ему присвоен от ""Источника разрыва провода"" (родителя)" & vbCrLf & vbCrLf & kem & " -X- " & kogo, vbOKOnly + vbCritical, "САПР-АСУ: Перезапись провода"
                                        SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                                        UnGlue Connects(1) 'Отклеиваем конец
            
                                    ElseIf Connects.ToSheet.Cells("Prop.Number").Result(0) = shpProvod.Cells("Prop.Number").Result(0) Then 'Номера проводов совпадают
                                    
                                        MsgBox "Номера проводов совпадают" & vbCrLf & vbCrLf & kem & " -X- " & kogo, vbOKOnly + vbCritical, "САПР-АСУ: Перезапись провода"
                                        SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                                        UnGlue Connects(1) 'Отклеиваем конец
            
                                    ElseIf Connects.ToSheet.Cells("Prop.Number").FormulaU Like "*!*" Then 'Нельзя перезаписать номер провода полученный по ссылке от друго провода
                                    
                                        MsgBox "Нельзя перезаписать номер провода(дочерний), полученный по ссылке от друго провода или разрыва провода" & vbCrLf & vbCrLf & kem & " -X- " & kogo, vbOKOnly + vbCritical, "САПР-АСУ: Перезапись провода"
                                        SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                                        UnGlue Connects(1) 'Отклеиваем конец
                                   
                                    Else
                                    
                                        'Ничего не мешает перезаписать провод
                                        Connects.ToSheet.Cells("Prop.Number").FormulaU = RefNashegoProvoda & "!Prop.Number" 'Записывам номер подключаемого провода в существующий (к которому подсоединились)
                                        Connects.ToSheet.Cells("Prop.SymName").FormulaU = RefNashegoProvoda & "!Prop.SymName" 'Записывам имя подключаемого провода в существующий (к которому подсоединились)
                                        Connects.ToSheet.Cells("Prop.AutoNum").FormulaU = False 'Убираем автонумерацию (т.к. номер получаем по ссылке от другого провода)
                                        Connects.ToSheet.Cells("User.AdrSource").FormulaU = Chr(34) & AdrNashegoProvoda & Chr(34) 'Сохраняем адрес источника номера
                                        Connects.ToSheet.Cells("User.AdrSource.Prompt").FormulaU = GUIDNashegoProvoda
                                        Connects.ToSheet.Cells("User.Shkaf").FormulaU = RefNashegoProvoda & "!User.Shkaf"
                                        Connects.ToSheet.Cells("User.Mesto").FormulaU = RefNashegoProvoda & "!User.Mesto"
            '                            Connects.ToSheet.Cells("Prop.HideNumber").FormulaU = True 'Скрываем номер (возможно)
            '                            Connects.ToSheet.Cells("Prop.HideName").FormulaU = True 'Скрываем название (возможно)
                                    End If
                                Else    'Если отказались перезаписывать провод
                                    SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                                    UnGlue Connects(1) 'Отклеиваем конец
                                End If
                            End If
                        End If
                    Else
                    'Если шейп, к которому подсоединили провод - оказался НЕ провод... (элемент)
                    
                        'если другой конец подсоединен к проводу - только убираем стрелку
                        SetArrow 0, Connects(1) 'Убираем стрелку
                        
                        'Если это начальный разрыв провода (родительский) - присваиваем ему имя и номер провода
                        If ShapeType = typeCxemaWireLinkS Then
                            Connects.ToSheet.Cells("Prop.Number").FormulaU = RefNashegoProvoda & "!Prop.Number" 'Записываем номер нашего провода
                            Connects.ToSheet.Cells("Prop.SymName").FormulaU = RefNashegoProvoda & "!Prop.SymName" 'Записываем имя нашего провода
                            Connects.ToSheet.Cells("User.AdrSource").FormulaU = Chr(34) & AdrNashegoProvoda & Chr(34) 'Сохраняем адрес источника номера
                            Connects.ToSheet.Cells("User.AdrSource.Prompt").FormulaU = GUIDNashegoProvoda
                            Connects.ToSheet.Cells("User.Shkaf").FormulaU = RefNashegoProvoda & "!User.Shkaf"
                            Connects.ToSheet.Cells("User.Mesto").FormulaU = RefNashegoProvoda & "!User.Mesto"
                        End If
                        
                        'если другой конец подсоединен НЕ к проводу и НЕ к конечному разрыву провода (дочернему) - присваиваем номер проводу
                        If (ShapeTypeNaDrugomKonce <> typeCxemaWire) And (ShapeTypeNaDrugomKonce <> typeCxemaWireLinkR) Then 'Смотрим что на другом конце НЕ провод и НЕ конечный разрыв провода (дочерний)
                            'Присваиваем номер проводу
        '                    shpProvod.Cells("Prop.SymName").FormulaU = """""" 'Чистим название провода
                            shpProvod.Cells("Prop.AutoNum").FormulaU = True 'Включаем автонумерацию (т.к. это независимый провод)
                            shpProvod.Cells("Prop.HideNumber").FormulaU = False 'Показываем номер
        '                    shpProvod.Cells("Prop.HideName").FormulaU = True 'Скрываем название
                            'Присваиваем номер проводу
                            AutoNum shpProvod
        
                        End If
                        
                        'Пишем номер провода в родительский ПЛК
                        If ShapeType = typePLCTerm Then
                            WireToPLCTerm shpProvod, Connects.ToSheet, True
                        End If
                        
                    End If
                Case Else
            End Select
            
            'Ищем Дочерних которые ссылаются не нас - отцепляем
            FindZombie shpProvod
        
    End Select
End Sub


Sub DisconnectWire(Connects As IVConnects)
'------------------------------------------------------------------------------------------------------------
' Macros        : DisconnectWire - Отцепляет провод от провода или элемента
                'В зависимости от того от чего отцепляем: провода, разрыва провода или элемента, производим чистку
                'полей имени, номера, источника номера. Убираем точку на конце и возвращаем красную стрелку
                'Макрос вызывается событием ConnectionsDeleted
'------------------------------------------------------------------------------------------------------------
    Dim shpProvod As Visio.Shape
    Dim AdrNashegoProvoda As String, GUIDNashegoProvoda As String, AdrSource As String, GUIDSource As String, AdrNaDrugomKonce As String
    Dim i As Integer, ii As Integer
    Dim ShapeType As Integer
    Dim ShapeTypeNaDrugomKonce As Integer
    
    Set shpProvod = Connects.FromSheet
    
    If bUnGlue Then bUnGlue = False: Exit Sub
    
    AdrSource = Connects.ToSheet.ContainingPage.NameU & "/" & Connects.ToSheet.NameID
    GUIDSource = Connects.ToSheet.UniqueID(visGetOrMakeGUID)
    AdrNashegoProvoda = shpProvod.ContainingPage.NameU & "/" & shpProvod.NameID
    GUIDNashegoProvoda = shpProvod.UniqueID(visGetOrMakeGUID)
    
    ShapeType = ShapeSAType(Connects.ToSheet) 'Тип шейпа, от которого отсоединили провод
    
    Select Case shpProvod.Connects.Count 'кол-во соединенных концов у провода
    
        Case 0 'С одной стороны
        
            'Оторвали от Любого (Источник номера (Провод или >- или Элемент) или Элемент)
            
            'Чистим наш
            shpProvod.Cells("Prop.Number").FormulaU = ""
            shpProvod.Cells("Prop.SymName").FormulaU = """"""
            shpProvod.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
            shpProvod.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
            shpProvod.Cells("Prop.AutoNum").FormulaU = False
            shpProvod.Cells("User.AdrSource").FormulaU = ""
            shpProvod.Cells("User.AdrSource.Prompt").FormulaU = ""
            SetArrow 254, Connects(1) 'Возвращаем красную стрелку
            shpProvod.Cells("Prop.HideNumber").FormulaU = False
            shpProvod.Cells("Prop.HideName").FormulaU = True
'            shpProvod.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
'            shpProvod.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
            
            'Пишем 0 в номер провода в родительский ПЛК
            If ShapeType = typePLCTerm Then
                WireToPLCTerm shpProvod, Connects.ToSheet, False
            End If
                
            'Но если он еще и Дочерний (Оторвали от Дочернего (Провод или ->))
            If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkS) Then
                If Connects.ToSheet.Cells("User.AdrSource").ResultStr(0) = AdrNashegoProvoda And Connects.ToSheet.Cells("User.AdrSource.Prompt").ResultStr(0) = GUIDNashegoProvoda Then 'Дочерний?
                    'Чистим Дочерний
                    Connects.ToSheet.Cells("Prop.Number").FormulaU = ""
                    Connects.ToSheet.Cells("Prop.SymName").FormulaU = """"""
                    Connects.ToSheet.Cells("User.AdrSource").FormulaU = ""
                    Connects.ToSheet.Cells("User.AdrSource.Prompt").FormulaU = ""
                    Connects.ToSheet.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                    Connects.ToSheet.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
                    
                    'Если это был провод - то + автонумерация дочернего провода
                    If ShapeType = typeCxemaWire Then
                        Connects.ToSheet.Cells("Prop.AutoNum").FormulaU = False
                        Connects.ToSheet.Cells("Prop.HideNumber").FormulaU = False
                        Connects.ToSheet.Cells("Prop.HideName").FormulaU = True
                        If Connects.ToSheet.Connects.Count = 2 Then
                            Connects.ToSheet.Cells("Prop.AutoNum").FormulaU = False
                            'Присваиваем номер проводу
                            AutoNum Connects.ToSheet
                        End If
                    End If
                 End If
            End If
            
        Case 1, 2 '1 - С двух сторон, 2 - С двух сторон, но в момент быстрого переприклеивания провода
            
            'Оторвали от Провода или ->
            If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkS) Then
                'От Дочернего
                If Connects.ToSheet.Cells("User.AdrSource").ResultStr(0) = AdrNashegoProvoda And Connects.ToSheet.Cells("User.AdrSource.Prompt").ResultStr(0) = GUIDNashegoProvoda Then 'Дочерний?
                
                    'Чистим Дочерний
                    Connects.ToSheet.Cells("Prop.Number").FormulaU = ""
                    Connects.ToSheet.Cells("Prop.SymName").FormulaU = """"""
                    Connects.ToSheet.Cells("User.AdrSource").FormulaU = ""
                    Connects.ToSheet.Cells("User.AdrSource.Prompt").FormulaU = ""
                    Connects.ToSheet.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                    Connects.ToSheet.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
                    SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                    
                    'Если это был провод - то + автонумерация дочернего провода
                    If ShapeType = typeCxemaWire Then
                        Connects.ToSheet.Cells("Prop.AutoNum").FormulaU = False
                        Connects.ToSheet.Cells("Prop.HideNumber").FormulaU = False
                        Connects.ToSheet.Cells("Prop.HideName").FormulaU = True
                        If Connects.ToSheet.Connects.Count = 2 Then
                            Connects.ToSheet.Cells("Prop.AutoNum").FormulaU = True
                            'Присваиваем номер проводу
                            AutoNum Connects.ToSheet
                        End If
                    End If
                Else
                'От НЕ Дочернего
                    'Чистим наш
                    shpProvod.Cells("Prop.Number").FormulaU = ""
                    shpProvod.Cells("Prop.SymName").FormulaU = """"""
                    shpProvod.Cells("User.AdrSource").FormulaU = ""
                    shpProvod.Cells("User.AdrSource.Prompt").FormulaU = ""
                    shpProvod.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                    shpProvod.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
                    shpProvod.Cells("Prop.AutoNum").FormulaU = False
                    SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                    shpProvod.Cells("Prop.HideNumber").FormulaU = False
                    shpProvod.Cells("Prop.HideName").FormulaU = True
                End If
            Else
            'Оторвали от Любого (Источник номера (Провод или >- или Элемент) или Элемент)
                'Находим шейп, на друм конце нашего провода
                For i = 1 To shpProvod.Connects.Count 'смотрим все соединения (их 2 :) )
                   If shpProvod.Connects(i).FromPart <> Connects(1).FromPart Then 'Отбрасывам то, которое только что произошло (берем другой конец)
                       AdrNaDrugomKonce = shpProvod.Connects(i).ToSheet.ContainingPage.NameU & "/" & shpProvod.Connects(i).ToSheet.NameID 'Адрес шейпа, на друм конце нашего провода
                       If shpProvod.Cells("User.AdrSource").ResultStr(0) <> AdrNaDrugomKonce And shpProvod.Cells("User.AdrSource.Prompt").ResultStr(0) <> shpProvod.Connects(i).ToSheet.UniqueID(visGetOrMakeGUID) Then 'Проверка на то что мы сами не являемся дочерним и на другом конце не провод или >-
                            'Чистим наш
                            shpProvod.Cells("Prop.Number").FormulaU = ""
                            shpProvod.Cells("Prop.SymName").FormulaU = """"""
                            shpProvod.Cells("User.AdrSource").FormulaU = ""
                            shpProvod.Cells("User.AdrSource.Prompt").FormulaU = ""
                            shpProvod.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                            shpProvod.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
                       End If
                   End If
                Next
                'являемся дочерним
                shpProvod.Cells("Prop.AutoNum").FormulaU = False
                SetArrow 254, Connects(1) 'Возвращаем красную стрелку
                'shpProvod.Cells("Prop.HideNumber").FormulaU = False
                'shpProvod.Cells("Prop.HideName").FormulaU = True
                
                'Пишем 0 в номер провода в родительский ПЛК
                If ShapeType = typePLCTerm Then
                    WireToPLCTerm shpProvod, Connects.ToSheet, False
                End If
                
            End If

    End Select
    
    'Ищем Дочерних которые ссылаются не нас - отцепляем
    FindZombie shpProvod
    
End Sub


Sub DeleteWire(DeletedShape As IVShape)
'------------------------------------------------------------------------------------------------------------
' Macros        : DeleteWire - Удаляет провод
                'Перебераем элементы секций Connects и FromConnects, производим чистку
                'полей имени, номера, источника номера.
                'У подключенных к нам проводов убираем точку на конце и возвращаем красную стрелку
                'Макрос вызывается событием BeforeShapeDelete
'------------------------------------------------------------------------------------------------------------
    Dim DeletedConnect As Visio.connect
    Dim ConnectedShape As Visio.Shape
    Dim i As Integer, ii As Integer
    Dim AdrNashegoProvoda As String, GUIDNashegoProvoda As String
    Dim ShapeType As Integer

    AdrNashegoProvoda = DeletedShape.ContainingPage.NameU & "/" & DeletedShape.NameID
    GUIDNashegoProvoda = DeletedShape.UniqueID(visGetOrMakeGUID)
    
    'Перебор Connects
    For i = 1 To DeletedShape.Connects.Count
        Set DeletedConnect = DeletedShape.Connects(i)
        Set ConnectedShape = DeletedConnect.ToSheet
        
        ShapeType = ShapeSAType(ConnectedShape)
        
        If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkS) Then
            If ConnectedShape.Cells("User.AdrSource").ResultStr(0) = AdrNashegoProvoda And ConnectedShape.Cells("User.AdrSource.Prompt").ResultStr(0) = GUIDNashegoProvoda Then
                'Чистим Дочерний
                ConnectedShape.Cells("Prop.Number").FormulaU = ""
                ConnectedShape.Cells("Prop.SymName").FormulaU = """"""
                ConnectedShape.Cells("User.AdrSource").FormulaU = ""
                ConnectedShape.Cells("User.AdrSource.Prompt").FormulaU = ""
                ConnectedShape.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                ConnectedShape.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"

                'Если это был провод - то + автонумерация дочернего провода
                If ShapeType = typeCxemaWire Then
                    ConnectedShape.Cells("Prop.AutoNum").FormulaU = False
                    ConnectedShape.Cells("Prop.HideNumber").FormulaU = False
                    ConnectedShape.Cells("Prop.HideName").FormulaU = True
                    If ConnectedShape.Connects.Count = 2 Then
                        ConnectedShape.Cells("Prop.AutoNum").FormulaU = True
                        'Присваиваем номер проводу
                        AutoNum ConnectedShape
                    Else
                        If ConnectedShape.Connects.Count = 1 Then
                            SetArrow 254, ConnectedShape.Connects(1) 'Возвращаем красную стрелку
                            UnGlue ConnectedShape.Connects(1) 'Отклеиваем конец
                        End If
                    End If
                End If
            End If
        End If
        
        'Пишем 0 в номер провода в родительский ПЛК
        If ShapeType = typePLCTerm Then
            WireToPLCTerm DeletedShape, DeletedConnect.ToSheet, False
        End If
        
    Next
    'Перебор FromConnects
    For i = 1 To DeletedShape.FromConnects.Count
        Set DeletedConnect = DeletedShape.FromConnects(i)
        Set ConnectedShape = DeletedConnect.FromSheet
        
        ShapeType = ShapeSAType(ConnectedShape)
        
        If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkS) Then
            If ConnectedShape.Cells("User.AdrSource").ResultStr(0) = AdrNashegoProvoda And ConnectedShape.Cells("User.AdrSource.Prompt").ResultStr(0) = GUIDNashegoProvoda Then
                'Чистим Дочерний
                ConnectedShape.Cells("Prop.Number").FormulaU = ""
                ConnectedShape.Cells("Prop.SymName").FormulaU = """"""
                ConnectedShape.Cells("User.AdrSource").FormulaU = ""
                ConnectedShape.Cells("User.AdrSource.Prompt").FormulaU = ""
                ConnectedShape.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
                ConnectedShape.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
                'Ищем каким концом дочерний приклеен к нам
                For ii = 1 To ConnectedShape.Connects.Count '(возможно это надо убрать под следующий if)
                    If ConnectedShape.Connects(ii).ToSheet = DeletedShape Then
                        SetArrow 254, ConnectedShape.Connects(ii) 'Возвращаем красную стрелку
                    End If
                Next
                'Если это был провод - то + автонумерация дочернего провода
                If ShapeType = typeCxemaWire Then
                    ConnectedShape.Cells("Prop.AutoNum").FormulaU = False
                    ConnectedShape.Cells("Prop.HideNumber").FormulaU = False
                    ConnectedShape.Cells("Prop.HideName").FormulaU = True
                    If ConnectedShape.Connects.Count = 2 Then
                        ConnectedShape.Cells("Prop.AutoNum").FormulaU = True
                        'Присваиваем номер проводу
                        AutoNum ConnectedShape
                    End If
                End If
            End If
        End If
    Next
End Sub

Sub ClearWire(vsoShape As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : ClearWire - Чистит при копировании
                'Чистим номер и ссылку при копировании провода.
                'В EventMultiDrop должна быть формула = CALLTHIS("WireNet.ClearWire", "SAPR_ASU")
'------------------------------------------------------------------------------------------------------------
    'If ThisDocument.BlockMacros Then Exit Sub
    'Если подключен 1-м концом и адрес дочерний - ничего не делаем
    If vsoShape.Connects.Count = 1 And vsoShape.Cells("User.AdrSource").ResultStr(0) <> "0,0000" Then
    Else
        'Чистим шейп
        vsoShape.CellsU("Prop.Number").FormulaU = ""
        vsoShape.CellsU("Prop.SymName").FormulaU = ""
        vsoShape.Cells("User.AdrSource").FormulaU = ""
        vsoShape.Cells("User.AdrSource.Prompt").FormulaU = ""
        vsoShape.Cells("User.Shkaf").FormulaU = "ThePage!Prop.SA_NazvanieShkafa"
        vsoShape.Cells("User.Mesto").FormulaU = "ThePage!Prop.SA_NazvanieMesta"
        vsoShape.Cells("Prop.AutoNum").FormulaU = False
        vsoShape.Cells("Prop.HideNumber").FormulaU = False
        vsoShape.Cells("Prop.HideName").FormulaU = True
        'Если подключен 2-мя концами - нумеруем
        If vsoShape.Connects.Count = 2 Then
            vsoShape.Cells("Prop.AutoNum").FormulaU = True
            'Присваиваем номер проводу
            AutoNum vsoShape
        End If
        'Если не подключен
        If vsoShape.Connects.Count = 0 Then
            vsoShape.Cells("Prop.AutoNum").FormulaU = True
            'Возвращаем красную стрелку
            vsoShape.Cells("BeginArrow").Formula = "USE(""endRedArrow"")"
            vsoShape.Cells("EndArrow").Formula = "USE(""endRedArrow"")"
        End If
    End If
End Sub


Sub SetArrow(Arrow As String, connect As IVConnect)
'------------------------------------------------------------------------------------------------------------
' Macros        : SetArrow - Задает вид окончания провода
'------------------------------------------------------------------------------------------------------------
    If Arrow = "254" Then Arrow = "USE(""endRedArrow"")"
    Select Case connect.FromPart
        Case visBegin
            connect.FromSheet.Cells("BeginArrow").Formula = Arrow
        Case visEnd
            connect.FromSheet.Cells("EndArrow").Formula = Arrow
    End Select
End Sub


Sub UnGlue(connect As IVConnect)
'------------------------------------------------------------------------------------------------------------
' Macros        : UnGlue - Отклеивает окончание провода
'------------------------------------------------------------------------------------------------------------
    Select Case connect.FromPart
        Case visBegin
            connect.FromSheet.Cells("BeginX").FormulaU = Chr(34) & connect.FromSheet.Cells("BeginX").Result(0) & Chr(34)
            connect.FromSheet.Cells("BeginY").FormulaU = Chr(34) & connect.FromSheet.Cells("BeginY").Result(0) & Chr(34)
        Case visEnd
            connect.FromSheet.Cells("EndX").FormulaU = Chr(34) & connect.FromSheet.Cells("EndX").Result(0) & Chr(34)
            connect.FromSheet.Cells("EndY").FormulaU = Chr(34) & connect.FromSheet.Cells("EndY").Result(0) & Chr(34)
    End Select
    If ShapeSATypeIs(connect.ToSheet, typeCxemaWire) Then connect.ToSheet.DeleteRow visSectionConnectionPts, visRowLast 'Удаляем последнюю точку
    bUnGlue = True
End Sub


Sub FindZombie(shpProvod As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : FindZombie - Ищем Дочерних которые ссылаются не на нас - отцепляем
'------------------------------------------------------------------------------------------------------------
    Dim DeletedConnect As Visio.connect
    Dim ConnectedShape As Visio.Shape
    Dim AdrNashegoProvoda As String, GUIDNashegoProvoda As String
    Dim i As Integer, ii As Integer
    Dim ShapeType As Integer
    
    AdrNashegoProvoda = shpProvod.ContainingPage.NameU & "/" & shpProvod.NameID
    GUIDNashegoProvoda = shpProvod.UniqueID(visGetOrMakeGUID)
    
    'Ищем Дочерних которые ссылаются не на нас - отцепляем. Перебор FromConnects.
    For i = 1 To shpProvod.FromConnects.Count
        If i > shpProvod.FromConnects.Count Then Exit For
        Set DeletedConnect = shpProvod.FromConnects(i)
        Set ConnectedShape = DeletedConnect.FromSheet
        
        ShapeType = ShapeSAType(ConnectedShape)
        
        If (ShapeType = typeCxemaWire) Or (ShapeType = typeCxemaWireLinkS) Then
            If ConnectedShape.Cells("User.AdrSource").ResultStr(0) <> AdrNashegoProvoda And ConnectedShape.Cells("User.AdrSource.Prompt").ResultStr(0) = GUIDNashegoProvoda Then 'Дочерний - но ссылается не нас - отцепляем
                'Ищем каким концом дочерний приклеен к нам
                For ii = 1 To ConnectedShape.Connects.Count
                    If ii > ConnectedShape.Connects.Count Then Exit For
                    If ConnectedShape.Connects(ii).ToSheet = shpProvod Then
                        SetArrow 254, ConnectedShape.Connects(ii) 'Возвращаем красную стрелку
                        UnGlue ConnectedShape.Connects(ii) 'Отклеиваем
                    End If
                Next
            End If
        End If
    Next
End Sub

Sub HideWireNumChildOnPage()
    HideWireNumChild ActivePage, 1
End Sub

Sub HideWireNumChildInDoc()
    Dim vsoPage As Visio.Page
    Dim PageName As String
    PageName = cListNameCxema  'Имена листов
    For Each vsoPage In ActiveDocument.Pages    'Перебираем все листы в активном документе
        If InStr(1, vsoPage.name, PageName) > 0 Then    'Берем те, что содержат "Схема" в имени
            ShowHideWireNumChild vsoPage, 1
        End If
    Next
End Sub

Sub ShowWireNumChildInDoc()
    Dim vsoPage As Visio.Page
    Dim PageName As String
    PageName = cListNameCxema  'Имена листов
    For Each vsoPage In ActiveDocument.Pages    'Перебираем все листы в активном документе
        If InStr(1, vsoPage.name, PageName) > 0 Then    'Берем те, что содержат "Схема" в имени
            ShowHideWireNumChild vsoPage, 0
        End If
    Next
End Sub

Public Sub ShowHideWireNumChild(vsoPage As Visio.Page, Hide As Boolean)
'------------------------------------------------------------------------------------------------------------
' Macros        : ShowHideWireNumChild - Скрывает/Показывает номера в дочерних проводах (номера полученные по ссылке)
                'При скрытии на листе остаются только провода с уникальными именами/номерами
                'Номера ВСЕХ проводов нужны только при рисовании схемы - для контроля правильности соединения
'------------------------------------------------------------------------------------------------------------
    Dim vsoShapeOnPage As Visio.Shape
    
    'Цикл поиска проводов и скрытия номера
    For Each vsoShapeOnPage In vsoPage.Shapes    'Перебираем все шейпы на листе
        If ShapeSATypeIs(vsoShapeOnPage, typeCxemaWire) Then     'Если в шейпе есть тип, то проверяем чтобы был провод
            If vsoShapeOnPage.Cells("Prop.AutoNum").Result(0) = 0 Then    'Отсеиваем шейпы нумеруемые в автомате
                If vsoShapeOnPage.Cells("Prop.Number").FormulaU Like "*!*" Then 'Находим дочерние
                    'Прячем номер/название
                    vsoShapeOnPage.Cells("Prop.HideNumber").FormulaU = Hide
'                    vsoShapeOnPage.Cells("Prop.HideName").FormulaU = Hide
                End If
            End If
        End If
    Next
End Sub

Sub WireToPLCTerm(shpProvod As Visio.Shape, shpPLCTerm As Visio.Shape, bConnect As Boolean)
'------------------------------------------------------------------------------------------------------------
' Macros        : WireToPLCTerm - При подключении провода к клемме входа ПЛК (дочернего)
                'записывает номер провода в родителя PLCIOParent
                'а там, если не 0 то появляется провод с номером подключенного провода,
                'при отключении - возвращаем 0
'------------------------------------------------------------------------------------------------------------
    Dim shpPLCIOParent As Visio.Shape
    Dim LinkWireNumber As String
    Dim PinNumber As Integer
    
    'Ссылка на номер провода
    LinkWireNumber = "Pages[" & shpProvod.ContainingPage.NameU & "]!" & shpProvod.NameID & "!Prop.Number"
    On Error GoTo ExitSub
    'Номер контакта во входе ПЛК
    PinNumber = CInt(Right(shpPLCTerm.name, 1))
    'Находим родительский вход ПЛК
    Set shpPLCIOParent = ShapeByGUID(shpPLCTerm.Parent.CellsU("Hyperlink.IO.ExtraInfo").ResultStr(0))
'    Set shpPLCIOParent = ShapeByGUID(shpPLCTerm.Parent.CellsU("Hyperlink.IO.ExtraInfo").ResultStr(0))
    'Пишем в него ссылку на номер провода или 0 (когда происходит отсоединение или удаление провода)
    shpPLCIOParent.CellsU("User.w" & PinNumber).FormulaU = IIf(bConnect, LinkWireNumber, 0)
ExitSub:
End Sub

Function FindParentOfTerm(shpTerm As Visio.Shape) As Visio.Shape
'------------------------------------------------------------------------------------------------------------
' Function      : FindParentOfTerm - Находит родительский шейп, в котором расположена клемма (рекурсивная)
                'Клеммы typePLCTerm и typeCxemaSensorTerm расположеные в typeCxemaElement, typePLCChild, typeCxemaParent, typeCxemaActuator, typeCxemaSensor
'-----------------------------------------------------------------------------------------------------------
    If shpTerm.Parent.CellExists("User.Shkaf", 0) Then
        Set FindParentOfTerm = shpTerm.Parent
    Else
        Set FindParentOfTerm = FindParentOfTerm(shpTerm.Parent)
    End If
End Function