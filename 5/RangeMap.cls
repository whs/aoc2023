VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "RangeMap"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'[Dest, Dest + Len)
Public Dest As LongLong
'[Src, Src + Len)
Public Src As LongLong
Public Length As LongLong

Public Sub From(d As LongLong, s As LongLong, l As LongLong)
    Dest = d
    Src = s
    Length = l
End Sub


'Index of the last src member
Public Property Get DestEnd() As LongLong
    DestEnd = Dest + Length - 1
End Property

'Index of the last src member
Public Property Get SrcEnd() As LongLong
    SrcEnd = Src + Length - 1
End Property
