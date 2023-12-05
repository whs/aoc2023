VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} UserForm1 
   Caption         =   "Advent of Code 2023 - Day 5"
   ClientHeight    =   6240
   ClientLeft      =   108
   ClientTop       =   456
   ClientWidth     =   9348.001
   OleObjectBlob   =   "UserForm1.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "UserForm1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim Seeds() As LongLong
Dim SeedSoilMap() As New RangeMap
Dim SoilToFertilizerMap() As New RangeMap
Dim FertilizerToWaterMap() As New RangeMap
Dim WaterToLightMap() As New RangeMap
Dim LightToTemperatureMap() As New RangeMap
Dim TemperatureToHumidityMap() As New RangeMap
Dim HumidityToLocationMap() As New RangeMap

Function ParseInput(Problem As String)
    Lines = Split(Problem, vbCr & vbLf)
    
    'Seeds
    SeedsRaw = Split(Lines(0), " ")
    SeedCount = GetLength(SeedsRaw) - 1
    ReDim Seeds(0 To SeedCount - 1)
    For i = 0 To SeedCount - 1
        Casted = CLngLng(SeedsRaw(i + 1))
        Seeds(i) = Casted
    Next i
    
    ParseMap Lines, "seed-to-soil", SeedSoilMap
    ParseMap Lines, "soil-to-fertilizer", SoilToFertilizerMap
    ParseMap Lines, "fertilizer-to-water", FertilizerToWaterMap
    ParseMap Lines, "water-to-light", WaterToLightMap
    ParseMap Lines, "light-to-temperature", LightToTemperatureMap
    ParseMap Lines, "temperature-to-humidity", TemperatureToHumidityMap
    ParseMap Lines, "humidity-to-location", HumidityToLocationMap
End Function

Sub ParseMap(Lines As Variant, Name As String, ByRef Target As Variant)
    found = False
    Index = 0
    ReDim Target(0)
    
    For Each Line In Lines
        If found And Line = "" Then
            Exit For
        ElseIf found Then
            Cols = Split(Line, " ")
            ReDim Preserve Target(Index)
            Set Target(Index) = New RangeMap
            Target(Index).From CLngLng(Cols(0)), CLngLng(Cols(1)), CLngLng(Cols(2))
            Index = Index + 1
        ElseIf Line = Name & " map:" Then
            found = True
        End If
    Next Line
End Sub


Function GetLength(a As Variant) As Integer
    If IsEmpty(a) Then
        GetLength = 0
    Else
        GetLength = UBound(a) - LBound(a) + 1
    End If
End Function

Function GetMappedRange(ByRef Ranges As Variant, ByVal Index As LongLong) As LongLong
    For Each Rng In Ranges
        If Rng.Src <= Index And Rng.SrcEnd >= Index Then
            Offset = Index - Rng.Src
            GetMappedRange = Rng.Dest + Offset
            Exit Function
        End If
    Next Rng
    'If unmapped, then use the same output
    GetMappedRange = Index
End Function

Function Solve1() As String
    Debug.Print "New Solve1"
    Out = 9.22337203685478E+18
    For Each Seed In Seeds
        Soil = GetMappedRange(SeedSoilMap, Seed)
        Fertilizer = GetMappedRange(SoilToFertilizerMap, Soil)
        Water = GetMappedRange(FertilizerToWaterMap, Fertilizer)
        Light = GetMappedRange(WaterToLightMap, Water)
        Temperature = GetMappedRange(LightToTemperatureMap, Light)
        Humidity = GetMappedRange(TemperatureToHumidityMap, Temperature)
        Location = GetMappedRange(HumidityToLocationMap, Humidity)
        
        Debug.Print Seed & " - " & Soil & " - " & Fertilizer & " - " & Water & " - " & Light & " - " & Temperature & " - " & Humidity & " - " & Location
        If Location < Out Then
            Out = Location
        End If
    Next Seed
    Solve1 = Out
End Function

Function Solve2() As String
    Debug.Print "New Solve2"
    Out = 9.22337203685478E+18
    For i = 0 To GetLength(Seeds) - 1 Step 2
        RangeStart = Seeds(i)
        RangeLen = Seeds(i + 1)
        For Seed = RangeStart To RangeStart + RangeLen
            Soil = GetMappedRange(SeedSoilMap, Seed)
            Fertilizer = GetMappedRange(SoilToFertilizerMap, Soil)
            Water = GetMappedRange(FertilizerToWaterMap, Fertilizer)
            Light = GetMappedRange(WaterToLightMap, Water)
            Temperature = GetMappedRange(LightToTemperatureMap, Light)
            Humidity = GetMappedRange(TemperatureToHumidityMap, Temperature)
            Location = GetMappedRange(HumidityToLocationMap, Humidity)
            
            Debug.Print Seed & " - " & Soil & " - " & Fertilizer & " - " & Water & " - " & Light & " - " & Temperature & " - " & Humidity & " - " & Location
            If Location < Out Then
                Out = Location
            End If
        Next Seed
    Next i
    Solve2 = Out
End Function

Private Sub CommandButton1_Click()
    ParseInput (InputBox.Value)
    OutputBox.Value = Solve1()
End Sub

Private Sub CommandButton2_Click()
    ParseInput (InputBox.Value)
    OutputBox.Value = Solve2()
End Sub

