'-----------------------------------------------------------------------------
'                       Константы для маркировки шейпов
'                                SAPR_ASU_Type
'                Числа располагаются в User.SAType каждой фигуры
'-----------------------------------------------------------------------------

Public Const typeNO As Integer = 0 'Контакт NO (Дочерний)(Не нумеруется)
Public Const typeNC As Integer = 1 'Контакт NC (Дочерний)(Не нумеруется)

Public Const typeCoil As Integer = 2 'Катушка реле (Родительский) KL (Реле промежуточное), KM (Контактор электромагнитный), KT (Реле времени), KV (Реле напряжения), KK (Реле тепловое)
Public Const typeParent As Integer = 3 'Нумеруемый элемент схемы без катушки (Родительский) SA (Переключатель), SB (Кнопка), QF (Автомат 3ф), SF (Автомат 1ф), QSD (УЗО), QFD (Дифавтомат), QS (Выключатель нагрузки), QA (Автомат защиты двигателя), FU (Предохранитель), RU (Варистор), DD (ТРМ, ПЛК-моноблок)
Public Const typeElement As Integer = 4 'Нумеруемый элемент схемы без контактов (НЕ Родительский) HL (Лампа), XS (Розетка), HA (Звонок), UG (Блок питания), TV (Трансформатор), UZ (Частотник, Твердотельное реле)

'ПЛК - разнесенное отображение
Public Const typePLCTerm As Integer = 10 'Клемма внутри ПЛК. (НЕ Родительский) (Не нумеруется)
Public Const typePLCIOChild As Integer = 11 'Вход/Выход внутри дочернего модуля дочернего ПЛК. Содержит несколько клемм (НЕ Родительский) (Не нумеруется)
Public Const typePLCIOLParent As Integer = 12 'Вход/Выход левый внутри родительского модуля родительского ПЛК. Содержит несколько клемм (НЕ Родительский) (Не нумеруется)
Public Const typePLCIORParent As Integer = 14 'Вход/Выход правый внутри родительского модуля родительского ПЛК. Содержит несколько клемм (НЕ Родительский) (Не нумеруется)
Public Const typePLCModChild As Integer = 15 'Модуль внутри ПЛК. Содержит несколько Входов/Выходов (Дочерний)(Не нумеруется)
Public Const typePLCChild As Integer = 16 'Кусок ПЛК при разнесенном отображении. Содержит несколько Модулей (Дочерний)(Не нумеруется)
Public Const typePLCModParent As Integer = 17 'Модуль при разнесенном ПЛК. Содержит описание Входов/Выходов в виде монтажного отбражения (Родительский)(Нумеруется вручную) AI DI AO DO
Public Const typePLCParent As Integer = 18 'ПЛК при разнесенном отображении. Содержит ВСЕ модули в виде монтажного отбражения (Родительский)  DD

Public Const typeThumb As Integer = 30 'Миниатюры контактов (Не нумеруется)

Public Const typeWireLinkS As Integer = 40 'Разрыв провода Источник (Родительский)(Не нумеруется)
Public Const typeWireLinkR As Integer = 45 'Разрыв провода Приемник (Дочерний)(Не нумеруется)

Public Const typeTerm As Integer = 50 'Клеммы в шкафу, в распределительной коробке

Public Const typeWire As Integer = 60 'Провода внутри шкафа

Public Const typeCableSH As Integer = 70 'Кабель вне шкафа на схеме электрической принципиальной
Public Const typeCableVP As Integer = 80 'Кабель вне шкафа на схеме внешних проводок (Не нумеруется)
Public Const typeCablePL As Integer = 90 'Кабель вне шкафа на ПЛАНЕ оборудования и КИП (Не нумеруется)

Public Const typeVynoskaPL As Integer = 95 'Выноска на ПЛАНЕ оборудования и КИП (Не нумеруется)
Public Const typeVynoska2PL As Integer = 96 'Выноска2 на ПЛАНЕ оборудования и КИП (Не нумеруется)

Public Const typeActuator As Integer = 100 'Привод вне шкафа. Аналогичен typeSensor M (Электродвигатель), YA (Клапан электромагнитный)
Public Const typeSensor As Integer = 110 'Датчик вне шкафа. Содержит несколько Входов/Выходов. (Родительский) RK (Датчик температуры TE) TC (Термопара TE), BP (Датчик давления PT), SP (Реле давления PS), BL (Датчик пламени BE), SQ (Концевик GS), SK (Термостат TS), UZ (Частотник UZ), BN (Сигнализатор загазованности QN)
Public Const typeSensorIO As Integer = 111 'Вход/Выход внутри датчика вне шкафа. Содержит несколько клемм (Не нумеруется)
Public Const typeSensorTerm As Integer = 112 'Клемма внутри typeSensorIO внутри датчика вне шкафа.

Public Const typeFSASensor As Integer = 120 'Датчик на ФСА
Public Const typeFSAActuator As Integer = 121 'Привод на ФСА
Public Const typeFSAPodval As Integer = 122 'Подвал на ФСА
Public Const typePlanSensor As Integer = 123 'Датчик на ПЛАНЕ
Public Const typePlanActuator As Integer = 124 'Привод на ПЛАНЕ

Public Const typeShkafMesto As Integer = 130 'Шкафы, распределительные коробки на схеме электрической (Не нумеруется)
Public Const typeBox As Integer = 140 'Шкафы, распределительные коробки на ПЛАНЕ (Не нумеруется)

Public Const typeElectroOneWire As Integer = 150 'Однолинейная схема

Public Const typeVidShkafaDIN As Integer = 160 'Внешний вид шкафа. Элементы внутри (на дин-рейке) (Не нумеруется)
Public Const typeVidShkafaDver As Integer = 161 'Внешний вид шкафа. Элементы снаружи (на двери)(Не нумеруется)
Public Const typeVidShkafaShkaf As Integer = 162 'Внешний вид шкафа. Сам шкаф(Не нумеруется)
Public Const typeVidShkafaKomp As Integer = 163 'Внешний вид шкафа. Комплектующие шкафа (дин-рейки, кабель-каналы, распределительные блоки, нулевые шины)(Не нумеруется)

Public Const typeDuctPlan As Integer = 170 'Лотки на ПЛАНЕ, кабельные трассы (Не нумеруется)
Public Const typeDuctElectroPlan As Integer = 180 'ЭС ЭО Лотки на плане
Public Const typeDuctOPSPlan As Integer = 190 'ОПС Лотки на плане

'-----------------------------------------------------------------------------
'                       Константы имен листов проекта
'-----------------------------------------------------------------------------
Public Const cListNameOD As String = "ОД" 'Общие указания
Public Const cListNameFSA As String = "ФСА" 'Схема функциональная автоматизации
Public Const cListNamePlan As String = "План" 'План расположения оборудования и приборов КИП
Public Const cListNameCxema As String = "Схема" 'Схема электрическая принципиальная
Public Const cListNameVID As String = "ВИД" 'Чертеж внешнего вида шкафа
Public Const cListNameSVP As String = "СВП" 'Схема соединения внешних проводок
Public Const cListNameKJ As String = "КЖ" 'Кабельный журнал
Public Const cListNameSpec As String = "С" 'Спецификация оборудования, изделий и материалов
