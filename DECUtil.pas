unit DECUtil;

interface

uses SysUtils, Classes;

{$I VER.INC}

const
// String Formats
  fmtDEFAULT     =    -1;     // use DefaultStringFormat
  fmtNONE        =     0;     // allways an Empty String, nothing Action
  fmtCOPY        =     1;     // One to One binary (input = output)
  fmtHEX         =    16;     // Hexadecimal
  fmtHEXL        =  1016;     // Hexadecimal lowercase
  fmtMIME64      = $1064;     // MIME Base 64
  fmtUU          = $5555;     // UU Coding  $5555 = 'UU'
  fmtXX          = $5858;     // XX Coding  $5858 = 'XX'

// 2 - 64 reserved for Formats to the Base 2 - 64
// over 1000 all other Formats

type
{$IFNDEF VER_D4H}
  LongWord       = LongInt;
  PLongWord      = ^LongWord;
{$ENDIF}
  PByte          = ^Byte;
  PInteger       = ^LongWord;
  PWord          = ^Word;
  PIntArray      = ^TIntArray;
  TIntArray      = array[0..1023] of LongWord;

  EProtection    = class(Exception);
  EStringFormat  = class(Exception);

// basic Class for all Protection Classes, TCipher, THash, TRandom
// TProtect can build a chain with varios Encryption Algos.
// i.E. CodeBuffer() can en/decode the Buffer with more as one Cipher when
// property Protection is set to a other Cipher :-)
  TPAction  = (paEncode, paDecode, paScramble, paCalc, paWipe);
  TPActions = set of TPAction;

{$IFDEF VER_D3H}
  TProtection = class(TInterfacedObject)
  private
{$ELSE}
  TProtection = class(TObject)
  private
    FRefCount: Integer;
{$ENDIF}
    FProtection: TProtection;
    FActions: TPActions;
    function GetProtection: TProtection;
    procedure SetProtection(Value: TProtection);
  protected
    procedure CodeInit(Action: TPAction); virtual;
    procedure CodeDone(Action: TPAction); virtual;
    procedure CodeBuf(var Buffer; const BufferSize: Integer; Action: TPAction); virtual;
  public
    constructor Create(AProtection: TProtection);
    destructor Destroy; override;

    class function Identity: Word;

    function Release: Integer;
    function AddRef: Integer;

    procedure CodeStream(Source, Dest: TStream; DataSize: Integer; Action: TPAction); virtual;
    procedure CodeFile(const Source, Dest: String; Action: TPAction); virtual;
    function  CodeString(const Source: String; Action: TPAction; Format: Integer): String; virtual;
    function  CodeBuffer(var Buffer; BufferSize: Integer; Action: TPAction): Integer; virtual;
// Protection Object, to cascade more Protection
    property Protection: TProtection read GetProtection write SetProtection;
    property Actions: TPActions read FActions write FActions default [paEncode..paWipe];
{$IFNDEF VER_D3H}
    property RefCount: Integer read FRefCount;
{$ENDIF}
  end;

// String converting
  
  TStringFormatClass = class of TStringFormat;

  TStringFormat = class(TObject) // for binary one to one convert = fmtCOPY
  public
    class function ToStr(Value: PChar; Len: Integer): String; virtual;
    class function StrTo(Value: PChar; Len: Integer): String; virtual;
    class function Name: String; virtual;
    class function Format: Integer; virtual;
    class function IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean; virtual;
  end;

  TStringFormat_HEX = class(TStringFormat) // Hexadecimal = fmtHEX
  public
    class function ToStr(Value: PChar; Len: Integer): String; override;
    class function StrTo(Value: PChar; Len: Integer): String; override;
    class function Name: String; override;
    class function Format: Integer; override;
    class function IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean; override;
    class function CharTable: PChar; virtual;
  end;

  TStringFormat_HEXL = class(TStringFormat_HEX) // Hexadecimal lowercase = fmtHEXL
  public
    class function Name: String; override;
    class function Format: Integer; override;
    class function CharTable: PChar; override;
  end;

  TStringFormat_MIME64 = class(TStringFormat_HEX)  // MIME Base 64 = fmtMIME64
  public
    class function ToStr(Value: PChar; Len: Integer): String; override;
    class function StrTo(Value: PChar; Len: Integer): String; override;
    class function Name: String; override;
    class function Format: Integer; override;
    class function CharTable: PChar; override;
  end;

  TStringFormat_UU = class(TStringFormat) // UU Encode = fmtUU
  public
    class function ToStr(Value: PChar; Len: Integer): String; override;
    class function StrTo(Value: PChar; Len: Integer): String; override;
    class function Name: String; override;
    class function Format: Integer; override;
    class function IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean; override;
    class function CharTable: PChar; virtual;
  end;

  TStringFormat_XX = class(TStringFormat_UU) // XX Encode = fmtXX
  public
    class function Name: String; override;
    class function Format: Integer; override;
    class function CharTable: PChar; override;
  end;

{Progress (gauge) for Hash and Cipher}
  TProgressEvent = procedure(Sender: TObject; Current, Maximal: Integer) of Object;

//calculate CRCR16/CRC32 Checksum, CRC is default $FFFFFFFF,
//after calc you must inverse Result with NOT
function CRC16(CRC: Word; Data: Pointer; DataSize: LongWord): Word;
function CRC32(CRC: LongWord; Data: Pointer; DataSize: LongWord): LongWord;
// the basicly used TestVector for all Hash/Cipher classes
// used for SelfTest, random Data, don't modify
function GetTestVector: PChar; register;

// String/Format routines
// convert any String to Format
function StrToFormat(Value: PChar; Len, Format: Integer): String;
// convert any Format to String
function FormatToStr(Value: PChar; Len, Format: Integer): String;
// convert any Format to Format
function ConvertFormat(Value: PChar; Len, FromFormat, ToFormat: Integer): String;
// Check is String convertable to Format
function IsValidString(Value: PChar; Len, Format: Integer): Boolean;
// Check is Format an valid Format
function IsValidFormat(Value: PChar; Len, Format: Integer): Boolean;
// register a new Format
procedure RegisterStringFormats(const StringFormats: array of TStringFormatClass);
// give all registered Formats in Strings
procedure GetStringFormats(Strings: TStrings);
// the Default, = fmtMIME64
function DefaultStringFormat: Integer;
// set the Default
procedure SetDefaultStringFormat(Format: Integer);
// give StringFormatClass from Format
function StringFormat(Format: Integer): TStringFormatClass;
// insert #13#10 Chars in Blocks from BlockSize
function InsertCR(const Value: String; BlockSize: Integer): String;
// delete all #13 and #10 Chars
function DeleteCR(const Value: String): String;
// format any String to a Block
function InsertBlocks(const Value, BlockStart, BlockEnd: String; BlockSize: Integer): String;
// remove any Block format
function RemoveBlocks(const Value, BlockStart, BlockEnd: String): String;
// give back a shorter Name, i.E. THash_MD4 -> "MD4" or TCipher_Blowfish -> "Blowfish"
function GetShortClassName(Value: TClass): String;

// Result := Value shl Shift or Value shr (32 - Shift)
function ROL(Value: LongWord; Shift: Integer): LongWord;
// Result := ROL(Value, Shift) + Add
function ROLADD(Value, Add: LongWord; Shift: Integer): LongWord;
// Result := ROL(Value, Shift) - Sub
function ROLSUB(Value, Sub: LongWord; Shift: Integer): LongWord;
// Result := Value shr Shift or Value shl (32 - Shift)
function ROR(Value: LongWord; Shift: Integer): LongWord;
// Result := ROR(Value, Shift) + Add
function RORADD(Value, Add: LongWord; Shift: Integer): LongWord;
// Result := ROR(Value, Shift) - Sub
function RORSUB(Value, Sub: LongWord; Shift: Integer): LongWord;
// Reverse the Bitorder from Value
function SwapBits(Value: LongWord): LongWord;
// Index of Least Significant Bit from Value
function LSBit(Value: Integer): Integer;
// Index of Most Significant Bit from Value
function MSBit(Value: Integer): Integer;
// Check iff only One Bit is set and give back the Index
function OneBit(Value: Integer): Integer;
// Compare Memory, D2 have no CompareMem, Result can be -1, 0, 1
function MemCompare(P1, P2: Pointer; Size: Integer): Integer;
// XOR's Buffers I1 and I2 Size Bytes to Dest
procedure XORBuffers(I1, I2: Pointer; Size: Integer; Dest: Pointer);
// Processor Type
function CPUType: Integer; {3 = 386, 4 = 486, 5 = Pentium, 6 > Pentium i.E. PII}
// call a installed Progress Event
procedure DoProgress(Sender: TObject; Current, Maximal: Integer);
// saver Test
function IsObject(AObject: Pointer; AClass: TClass): Boolean;
// Time Seed produced from GetSystemTime and QueryPerformanceCounter
function RndTimeSeed: Integer;
// XOR Buffer Size Bytes with Seed Randoms,
// the initial State from Buffer have effect on the Output
function RndXORBuffer(Seed: Integer; var Buffer; Size: Integer): Integer;
// encapsulate QueryPerformanceCounter/Frequency
function PerfCounter: Comp;
function PerfFreq: Comp;

const
  InitTestIsOk        : Boolean  = False;
  IdentityBase        : Word     = $1234;

{this is set to SwapInt for <= 386 and BSwapInt >= 486 CPU, don't modify}
  SwapInteger       : function(Value: LongWord): LongWord; register  = nil;
{Count of Integers Buffer}
  SwapIntegerBuffer : procedure(Source, Dest: Pointer; Count: Integer); register = nil;
{Progress callback function, set this to your Progresscallback}
  Progress: TProgressEvent = nil;

implementation

uses Windows, DECConst;

const
  FCPUType : Integer = 0;
  FStrFMTs : TList = nil;         // registered Stringformats
  FStrFMT  : Integer = fmtMIME64; // Default Stringformat

function PerfCounter: Comp;
begin
{$IFDEF VER_D4H}
  if not QueryPerformanceCounter(TULargeInteger(Result).QuadPart) then
{$ELSE}
  if not QueryPerformanceCounter(TLargeInteger(Result)) then
{$ENDIF}
    Result := GetTickCount;
end;

function PerfFreq: Comp;
begin
{$IFDEF VER_D4H}
  if not QueryPerformanceFrequency(TULargeInteger(Result).QuadPart) then
{$ELSE}
  if not QueryPerformanceFrequency(TLargeInteger(Result)) then
{$ENDIF}
    Result := 1000;
end;

function DefaultStringFormat: Integer;
begin
  Result := FStrFMT;
end;

procedure SetDefaultStringFormat(Format: Integer);
begin
  if (Format = fmtDEFAULT) or (StringFormat(Format) = nil) then FStrFMT := fmtMIME64
    else FStrFMT := Format;
end;

// TProtection Class
function TProtection.GetProtection: TProtection;
begin
  if (FProtection <> nil) and not IsObject(FProtection, TProtection) then FProtection := nil;
  Result := FProtection;
end;

procedure TProtection.SetProtection(Value: TProtection);

  function CheckProtection(P: TProtection): Boolean;
  begin
    Result := True;
    if IsObject(P, TProtection) then
      if P = Self then Result := False
        else Result := CheckProtection(P.FProtection)
  end;

begin
  if Value <> FProtection then
    if CheckProtection(Value) then
    begin
      FProtection.Release;
      FProtection := Value;
      FProtection.AddRef;
    end else raise EProtection.Create(sProtectionCircular)
end;

procedure TProtection.CodeInit(Action: TPAction);
begin
  if Protection <> nil then Protection.CodeInit(Action);
end;

procedure TProtection.CodeDone(Action: TPAction);
begin
  if Protection <> nil then Protection.CodeDone(Action);
end;

procedure TProtection.CodeBuf(var Buffer; const BufferSize: Integer; Action: TPAction);
begin
  if Protection <> nil then Protection.CodeBuf(Buffer, BufferSize, Action);
end;

function TProtection.Release: Integer;
begin
  if IsObject(Self, TProtection) then
  begin
{$IFDEF VER_D3H}
    Result := IUnknown(Self)._Release;
{$ELSE}
    Dec(FRefCount);
    Result := FRefCount;
    if FRefCount = 0 then Destroy;
{$ENDIF}
  end else Result := 0;
end;

function TProtection.AddRef: Integer;
begin
  if IsObject(Self, TProtection) then
  begin
{$IFDEF VER_D3H}
    Result := IUnknown(Self)._AddRef;
{$ELSE}
    Inc(FRefCount);
    Result := FRefCount;
{$ENDIF}
  end else Result := 0;
end;

procedure TProtection.CodeStream(Source, Dest: TStream; DataSize: Integer; Action: TPAction);
const
  maxBufSize = 1024 * 4;
var
  Buf: PChar;
  SPos: Integer;
  DPos: Integer;
  Len: Integer;
  Size: Integer;
begin
  if Source = nil then Exit;
  if Dest = nil then Dest := Source;
  if DataSize < 0 then
  begin
    DataSize := Source.Size;
    Source.Position := 0;
  end;
  CodeInit(Action);
  Buf := nil;
  Size := DataSize;
  DoProgress(Self, 0, Size);
  try
    Buf    := AllocMem(maxBufSize);
    DPos   := Dest.Position;
    SPos   := Source.Position;
    if Action = paCalc then
    begin
      while DataSize > 0 do
      begin
        Len := DataSize;
        if Len > maxBufSize then Len := maxBufSize;
        Len := Source.Read(Buf^, Len);
        if Len <= 0 then Break;
        CodeBuf(Buf^, Len, paCalc);
        Dec(DataSize, Len);
        DoProgress(Self, Size - DataSize, Size);
      end;
    end else
    begin
      while DataSize > 0 do
      begin
        Source.Position := SPos;
        Len := DataSize;
        if Len > maxBufSize then Len := maxBufSize;
        Len := Source.Read(Buf^, Len);
        SPos := Source.Position;
        if Len <= 0 then Break;
        CodeBuf(Buf^, Len, Action);
        Dest.Position := DPos;
        Dest.Write(Buf^, Len);
        DPos := Dest.Position;
        Dec(DataSize, Len);
        DoProgress(Self, Size - DataSize, Size);
      end;
    end;
  finally
    DoProgress(Self, 0, 0);
    ReallocMem(Buf, 0);
    CodeDone(Action);
  end;
end;

procedure TProtection.CodeFile(const Source, Dest: String; Action: TPAction);
var
  S,D: TFileStream;
begin
  S := nil;
  D := nil;
  try
    if (AnsiCompareText(Source, Dest) <> 0) and ((Trim(Dest) <> '') or (Action = paCalc)) then
    begin
      S := TFileStream.Create(Source, fmOpenRead or fmShareDenyNone);
      if Action = paCalc then D := S
        else D := TFileStream.Create(Dest, fmCreate);
    end else
    begin
      S := TFileStream.Create(Source, fmOpenReadWrite);
      D := S;
    end;
    CodeStream(S, D, S.Size, Action);
  finally
    S.Free;
    if S <> D then
    begin
{$IFDEF VER_D3H}
      D.Size := D.Position;
{$ENDIF}
      D.Free;
    end;
  end;
end;

function TProtection.CodeBuffer(var Buffer; BufferSize: Integer; Action: TPAction): Integer;
begin
  Result := BufferSize;
  CodeInit(Action);
  try
    CodeBuf(Buffer, BufferSize, Action);
  finally
    CodeDone(Action);
  end;
end;

function TProtection.CodeString(const Source: String; Action: TPAction; Format: Integer): String;
var
  M: TMemoryStream;
begin
  Result := '';
  if Length(Source) <= 0 then Exit;
  M := TMemoryStream.Create;
  try
    if Action <> paDecode then Result := Source
      else Result := FormatToStr(PChar(Source), Length(Source), Format);
    M.Write(PChar(Result)^, Length(Result));
    M.Position := 0;
    CodeStream(M, M, M.Size, Action);
    if Action = paDecode then
    begin
      SetLength(Result, M.Size);
      Move(M.Memory^, PChar(Result)^, M.Size);
    end else
      Result := StrToFormat(M.Memory, M.Size, Format);
  finally
    M.Free;
  end;
end;

constructor TProtection.Create(AProtection: TProtection);
begin
  inherited Create;
  Protection := AProtection;
  FActions := [paEncode..paWipe];
end;

destructor TProtection.Destroy;
begin
  Protection := nil;
  inherited Destroy;
end;

class function TProtection.Identity: Word;
var
  S: String;
begin
  S := ClassName;
  Result := not CRC16(IdentityBase, PChar(S), Length(S));
end;

class function TStringFormat.ToStr(Value: PChar; Len: Integer): String;
begin
  SetLength(Result, Len);
  Move(Value^, PChar(Result)^, Len);
end;

class function TStringFormat.StrTo(Value: PChar; Len: Integer): String;
begin
  SetLength(Result, Len);
  Move(Value^, PChar(Result)^, Len);
end;

class function TStringFormat.Name: String;
begin
  if Self = TStringFormat then Result := sFMT_COPY
    else Result := GetShortClassName(Self);
end;

class function TStringFormat.Format: Integer;
begin
  Result := fmtCOPY;
end;

class function TStringFormat.IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean;
begin
  Result := True;
end;

function TableFind(Value: Char; Table: PChar; Len: Integer): Integer; assembler;
asm // Utility for TStringFormat_XXXXX
      PUSH  EDI
      MOV   EDI,EDX
      REPNE SCASB
      MOV   EAX,0
      JNE   @@1
      MOV   EAX,EDI
      SUB   EAX,EDX
@@1:  DEC   EAX
      POP   EDI
end;

class function TStringFormat_HEX.ToStr(Value: PChar; Len: Integer): String;
var
  D: PByte;
  T: PChar;
  I,P: Integer;
  HasIdent: Boolean;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len div 2 +1);
  T := CharTable;
  D := PByte(Result);
  I := 0;
  HasIdent := False;
  while Len > 0 do
  begin
    P := TableFind(UpCase(Value^), T, 18);
    Inc(Value);
    if P >= 0 then
      if P > 16 then
      begin
        if not HasIdent then
        begin
          HasIdent := True;
          I := 0;
          D := PByte(Result);
        end;
      end else
      begin
        if Odd(I) then
        begin
          D^ := D^ or P;
          Inc(D);
        end else D^ := P shl 4;
        Inc(I);
      end;
    Dec(Len);
  end;
  SetLength(Result, PChar(D) - PChar(Result));
end;

class function TStringFormat_HEX.StrTo(Value: PChar; Len: Integer): String;
var
  D,T: PChar;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len * 2);
  T := CharTable;
  D := PChar(Result);
  while Len > 0 do
  begin
    D[0] := T[Byte(Value^) shr  4];
    D[1] := T[Byte(Value^) and $F];
    Inc(D, 2);
    Inc(Value);
    Dec(Len);
  end;
end;

class function TStringFormat_HEX.IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean;
var
  T: PChar;
  L: Integer;
begin
  Result := not ToStr;
  if not Result then
  begin
    T := CharTable;
    L := StrLen(T);
    while Len > 0 do
      if TableFind(Value^, T, L) >= 0 then
      begin
        Dec(Len);
        Inc(Value);
      end else Exit;
  end;
  Result := True;
end;

class function TStringFormat_HEX.Name: String;
begin
  Result := sFMT_HEX;
end;

class function TStringFormat_HEX.Format: Integer;
begin
  Result := fmtHEX;
end;

class function TStringFormat_HEX.CharTable: PChar; assembler;
asm
      MOV  EAX,OFFSET @@1
      RET
@@1:  DB   '0123456789ABCDEF'     // Table must be >= 18 Chars
      DB   'X$ abcdefhHx()[]{},;:-_/\*+"''',9,10,13,0
end;

class function TStringFormat_HEXL.Name: String;
begin
  Result := sFMT_HEXL;
end;

class function TStringFormat_HEXL.Format: Integer;
begin
  Result := fmtHEXL;
end;

class function TStringFormat_HEXL.CharTable: PChar;
asm
      MOV  EAX,OFFSET @@1
      RET
@@1:  DB   '0123456789abcdef'     // Table must be >= 18 Chars
      DB   'X$ ABCDEFhHx()[]{},;:-_/\*+"''',9,10,13,0
end;

class function TStringFormat_MIME64.ToStr(Value: PChar; Len: Integer): String;
var
  B: Cardinal;
  J,I: Integer;
  S,D,L,T: PChar;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := Length(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len);
  Move(PChar(Value)^, PChar(Result)^, Len);
  T := CharTable;
  while Len mod 4 <> 0 do
  begin
    Result := Result + T[64];
    Inc(Len);
  end;
  D := PChar(Result);
  S := D;
  L := S + Len;
  Len := Len * 3 div 4;
  while Len > 0 do
  begin
    B := 0;
    J := 4;
    while (J > 0) and (S <= L) do
    begin
      I := TableFind(S^, T, 65);
      if I >= 0 then
      begin
        B := B shl 6;
        if I >= 64 then Dec(Len) else B := B or Byte(I);
        Dec(J);
      end;
      Inc(S);
    end;
    J := 2;
    repeat
      D[J] := Char(B);
      B := B shr 8;
      Dec(J);
    until J < 0;
    if Len > 3 then Inc(D, 3) else Inc(D, Len);
    Dec(Len, 3);
  end;
  SetLength(Result, D - PChar(Result));
end;

class function TStringFormat_MIME64.StrTo(Value: PChar; Len: Integer): String;
var
  B: Cardinal;
  I: Integer;
  D,T: PChar;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len * 4 div 3 + 4);
  D := PChar(Result);
  T := CharTable;
  while Len > 0 do
  begin
    B := 0;
    for I := 0 to 2 do
    begin
      B := B shl 8;
      if Len > 0 then
      begin
        B := B or Byte(Value^);
        Inc(Value);
      end;
      Dec(Len);
    end;
    for I := 3 downto 0 do
    begin
      if Len < 0 then
      begin
        D[I] := T[64];
        Inc(Len);
      end else D[I] := T[B and $3F];
      B := B shr 6;
    end;
    Inc(D, 4);
  end;
  SetLength(Result, D - PChar(Result));
end;

class function TStringFormat_MIME64.Name: String;
begin
  Result := sFMT_MIME64;
end;

class function TStringFormat_MIME64.Format: Integer;
begin
  Result := fmtMIME64;
end;

class function TStringFormat_MIME64.CharTable: PChar; assembler;
asm
      MOV  EAX,OFFSET @@1
      RET  // must be >= 65 Chars
@@1:  DB  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
      DB  ' $()[]{},;:-_\*"''',9,10,13,0
end;

class function TStringFormat_UU.ToStr(Value: PChar; Len: Integer): String;
var
  T,D,L: PChar;
  I,E: Integer;
  B: Cardinal;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len);
  L := Value + Len;
  D := PChar(Result);
  T := CharTable;
  repeat
    Len := TableFind(Value^, T, 64);
    if (Len < 0) or (Len > 45) then
      raise EStringFormat.CreateFMT(sInvalidStringFormat, [Name]);
    Inc(Value);
    while Len > 0 do
    begin
      B := 0;
      I := 4;
      while (I > 0) and (Value <= L) do
      begin
        E := TableFind(Value^, T, 64);
        if E >= 0 then
        begin
          B := B shl 6 or Byte(E);
          Dec(I);
        end;
        Inc(Value);
      end;
      I := 2;
      repeat
        D[I] := Char(B);
        B    := B shr 8;
        Dec(I);
      until I < 0;
      if Len > 3 then Inc(D, 3) else Inc(D, Len);
      Dec(Len, 3);
    end;
  until Value >= L;
  SetLength(Result, D - PChar(Result));
end;

class function TStringFormat_UU.StrTo(Value: PChar; Len: Integer): String;
var
  T,D: PChar;
  L,I: Integer;
  B: Cardinal;
begin
  Result := '';
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  SetLength(Result, Len * 4 div 3 + Len div 45 + 10);
  D := PChar(Result);
  T := CharTable;
  while Len > 0 do
  begin
    L := Len;
    if L > 45 then L := 45;
    Dec(Len, L);
    D^ := T[L];
    while L > 0 do
    begin
      B := 0;
      for I := 0 to 2 do
      begin
        B := B shl 8;
        if L > 0 then
        begin
          B := B or Byte(Value^);
          Inc(Value);
        end;
        Dec(L);
      end;
      for I := 4 downto 1 do
      begin
        D[I] := T[B and $3F];
        B := B shr 6;
      end;
      Inc(D, 4);
    end;
    Inc(D);
  end;
  SetLength(Result, D - PChar(Result));
end;

class function TStringFormat_UU.Name: String;
begin
  Result := sFMT_UU;
end;

class function TStringFormat_UU.Format: Integer;
begin
  Result := fmtUU;
end;

class function TStringFormat_UU.IsValid(Value: PChar; Len: Integer; ToStr: Boolean): Boolean;
var
  T: PChar;
  L,I,P: Integer;
begin
  Result := not ToStr;
  if not Result then
  begin
    T := CharTable;
    L := StrLen(T);
    P := 0;
    while Len > 0 do
    begin
      I := TableFind(Value^, T, L);
      if I >= 0 then
      begin
        Dec(Len);
        Inc(Value);
        if P = 0 then
        begin
          if I > 45 then Exit;
          P := (I * 4 + 2) div 3;
        end else
          if I < 64 then Dec(P);
      end else Exit;
    end;
    if P <> 0 then Exit;
  end;
  Result := True;
end;

class function TStringFormat_UU.CharTable: PChar;
asm
      MOV  EAX,OFFSET @@1
      RET  // must be >= 64 Chars
@@1:  DB   '`!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'
      DB   ' ',9,10,13,0
end;

class function TStringFormat_XX.Name: String;
begin
  Result := sFMT_XX;
end;

class function TStringFormat_XX.Format: Integer;
begin
  Result := fmtXX;
end;

class function TStringFormat_XX.CharTable: PChar;
asm
      MOV  EAX,OFFSET @@1
      RET
@@1:  DB   '+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      DB   ' "()[]''',9,10,13,0
end;

function CPUType: Integer;
begin
  Result := FCPUType;
end;

function IsObject(AObject: Pointer; AClass: TClass): Boolean;
var
  E: Pointer;
begin
  Result := False;
  if AObject = nil then Exit;
  E := ExceptionClass;
  ExceptionClass := nil;
  try
    if TObject(AObject) is AClass then Result := True;
  except
  end;
  ExceptionClass := E;
end;

function ROL(Value: LongWord; Shift: Integer): LongWord; assembler;
asm
       MOV   ECX,EDX
       ROL   EAX,CL
end;

function ROLADD(Value, Add: LongWord; Shift: Integer): LongWord; assembler;
asm
       ROL   EAX,CL
       ADD   EAX,EDX
end;

function ROLSUB(Value, Sub: LongWord; Shift: Integer): LongWord; assembler;
asm
       ROL   EAX,CL
       SUB   EAX,EDX
end;

function ROR(Value: LongWord; Shift: Integer): LongWord; assembler;
asm
       MOV   ECX,EDX
       ROR   EAX,CL
end;

function RORADD(Value, Add: LongWord; Shift: Integer): LongWord; assembler;
asm
       ROR  EAX,CL
       ADD  EAX,EDX
end;

function RORSUB(Value, Sub: LongWord; Shift: Integer): LongWord; assembler;
asm
       ROR  EAX,CL
       SUB  EAX,EDX
end;
{swap 4 Bytes Intel, Little/Big Endian Conversion}
function SwapInt(Value: LongWord): LongWord; assembler; register;
asm
       XCHG  AH,AL
       ROL   EAX,16
       XCHG  AH,AL
end;

function BSwapInt(Value: LongWord): LongWord; assembler; register;
asm
       BSWAP  EAX
end;

procedure SwapIntBuf(Source,Dest: Pointer; Count: Integer); assembler; register;
asm
       TEST   ECX,ECX
       JLE    @Exit
       PUSH   EBX
       SUB    EAX,4
       SUB    EDX,4
@@1:   MOV    EBX,[EAX + ECX * 4]
       XCHG   BL,BH
       ROL    EBX,16
       XCHG   BL,BH
       MOV    [EDX + ECX * 4],EBX
       DEC    ECX
       JNZ    @@1
       POP    EBX
@Exit:
end;

procedure BSwapIntBuf(Source, Dest: Pointer; Count: Integer); assembler; register;
asm
       TEST   ECX,ECX
       JLE    @Exit
       PUSH   EBX
       SUB    EAX,4
       SUB    EDX,4
@@1:   MOV    EBX,[EAX + ECX * 4]
       BSWAP  EBX
       MOV    [EDX + ECX * 4],EBX
       DEC    ECX
       JNZ    @@1
       POP    EBX
@Exit:
end;
{reverse the bit order from a integer}
function SwapBits(Value: LongWord): LongWord;
asm
       CMP    FCPUType,3
       JLE    @@1
       BSWAP  EAX
       JMP    @@2
@@1:   XCHG   AH,AL
       ROL    EAX,16
       XCHG   AH,AL
@@2:   MOV    EDX,EAX
       AND    EAX,0AAAAAAAAh
       SHR    EAX,1
       AND    EDX,055555555h
       SHL    EDX,1
       OR     EAX,EDX
       MOV    EDX,EAX
       AND    EAX,0CCCCCCCCh
       SHR    EAX,2
       AND    EDX,033333333h
       SHL    EDX,2
       OR     EAX,EDX
       MOV    EDX,EAX
       AND    EAX,0F0F0F0F0h
       SHR    EAX,4
       AND    EDX,00F0F0F0Fh
       SHL    EDX,4
       OR     EAX,EDX
end;

function LSBit(Value: Integer): Integer; assembler;
asm
       BSF   EAX,EAX
end;

function MSBit(Value: Integer): Integer; assembler;
asm
       BSR   EAX,EAX
end;

function OneBit(Value: Integer): Integer; assembler;
asm
       MOV   ECX,EAX
       MOV   EDX,EAX
       BSF   EDX,EDX
       JZ    @@1
       BSR   ECX,ECX
       CMP   ECX,EDX
       JNE   @@1
       MOV   EAX,EDX
       RET
@@1:   XOR   EAX,EAX
end;

function MemCompare(P1, P2: Pointer; Size: Integer): Integer; assembler; register;
asm
       PUSH    ESI
       PUSH    EDI
       MOV     ESI,P1
       MOV     EDI,P2
       XOR     EAX,EAX
       REPE    CMPSB
       JE      @@1
       MOVZX   EAX,BYTE PTR [ESI-1]
       MOVZX   EDX,BYTE PTR [EDI-1]
       SUB     EAX,EDX
@@1:   POP     EDI
       POP     ESI
end;

procedure XORBuffers(I1, I2: Pointer; Size: Integer; Dest: Pointer); assembler;
asm
       AND   ECX,ECX
       JZ    @@5
       PUSH  ESI
       PUSH  EDI
       MOV   ESI,EAX
       MOV   EDI,Dest
@@1:   TEST  ECX,3
       JNZ   @@3
@@2:   SUB   ECX,4
       JL    @@4
       MOV   EAX,[ESI + ECX]
       XOR   EAX,[EDX + ECX]
       MOV   [EDI + ECX],EAX
       JMP   @@2
@@3:   DEC   ECX
       MOV   AL,[ESI + ECX]
       XOR   AL,[EDX + ECX]
       MOV   [EDI + ECX],AL
       JMP   @@1
@@4:   POP   EDI
       POP   ESI
@@5:
end;

procedure DoProgress(Sender: TObject; Current, Maximal: Integer);
begin
{saver access}
  if (TMethod(Progress).Code <> nil) and
     ((TMethod(Progress).Data = nil) or
       IsObject(TMethod(Progress).Data, TObject)) then
    Progress(Sender, Current, Maximal);
end;

function StringFormat(Format: Integer): TStringFormatClass;
var
  I: Integer;
begin
  if Format = fmtDefault then Format := DefaultStringFormat;
  Result := nil;
  if FStrFmts <> nil then
    for I := 0 to FStrFMTs.Count-1 do
      if TStringFormatClass(FStrFmts[I]).Format = Format then
      begin
        Result := FStrFMTS[I];
        Exit;
      end;
end;

function StrToFormat(Value: PChar; Len, Format: Integer): String;
var
  Fmt: TStringFormatClass;
begin
  Result := '';
  if (Value = nil) or (Format = fmtNONE) then Exit;
  if Len <  0 then Len := StrLen(Value);
  if Len <= 0 then Exit;
  Fmt := StringFormat(Format);
  if Fmt <> nil then
    if Fmt.IsValid(Value, Len, False) then Result := Fmt.StrTo(Value, Len)
      else raise EStringFormat.CreateFMT(sInvalidFormatString, [FMT.Name])
    else raise EStringFormat.CreateFMT(sStringFormatExists, [Format]);
end;

function FormatToStr(Value: PChar; Len, Format: Integer): String;
var
  Fmt: TStringFormatClass;
begin
  Result := '';
  if (Value = nil) or (Format = fmtNONE) then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  Fmt := StringFormat(Format);
  if Fmt <> nil then
    if Fmt.IsValid(Value, Len, True) then Result := Fmt.ToStr(Value, Len)
      else raise EStringFormat.CreateFMT(sInvalidStringFormat, [FMT.Name])
    else raise EStringFormat.CreateFMT(sStringFormatExists, [Format]);
end;

function ConvertFormat(Value: PChar; Len, FromFormat, ToFormat: Integer): String;
begin
  Result := '';
  if (FromFormat = fmtNONE) or (ToFormat = fmtNONE) then Exit;
  if FromFormat <> ToFormat then
  begin
    Result := FormatToStr(Value, Len, FromFormat);
    Result := StrToFormat(PChar(Result), Length(Result), ToFormat);
  end else
  begin
    if Value = nil then Exit;
    if Len < 0 then Len := StrLen(Value);
    if Len = 0 then Exit;
    SetLength(Result, Len);
    Move(Value^, PChar(Result)^, Len);
  end;
end;

function IsValidFormat(Value: PChar; Len, Format: Integer): Boolean;
var
  Fmt: TStringFormatClass;
begin
  Result := True;
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  Fmt := StringFormat(Format);
  if Fmt = nil then Result := False
    else Result := Fmt.IsValid(Value, Len, True);
end;

function IsValidString(Value: PChar; Len, Format: Integer): Boolean;
var
  Fmt: TStringFormatClass;
begin
  Result := True;
  if Value = nil then Exit;
  if Len < 0 then Len := StrLen(Value);
  if Len = 0 then Exit;
  Fmt := StringFormat(Format);
  if Fmt = nil then Result := False
    else Result := Fmt.IsValid(Value, Len, False);
end;

procedure RegisterStringFormats(const StringFormats: array of TStringFormatClass);
var
  I,J: Integer;
  FMT: TStringFormatClass;
begin
  if FStrFMTs = nil then FStrFMTs := TList.Create;
  for I := Low(StringFormats) to High(StringFormats) do
    if (StringFormats[I] <> nil) and
       (StringFormats[I].Format <> fmtDEFAULT) then
    begin
      FMT := StringFormat(StringFormats[I].Format);
      if FMT <> nil then
      begin
        J := FStrFMTs.IndexOf(FMT);
        FStrFMTs[J] := StringFormats[I];
      end else FStrFMTs.Add(StringFormats[I]);
    end;
end;

procedure GetStringFormats(Strings: TStrings);
var
  I: Integer;
begin
  if IsObject(Strings, TStrings) and (FStrFMTs <> nil) then
    for I := 0 to FStrFMTs.Count-1 do
      Strings.AddObject(TStringFormatClass(FStrFMTs[I]).Name, FStrFMTs[I]);
end;

function InsertCR(const Value: String; BlockSize: Integer): String;
var
  I: Integer;
  S,D: PChar;
begin
  if (BlockSize <= 0) or (Length(Value) <= BlockSize) then
  begin
    Result := Value;
    Exit;
  end;
  I := Length(Value);
  SetLength(Result, I + I * 2 div BlockSize + 2);
  S := PChar(Value);
  D := PChar(Result);
  repeat
    Move(S^, D^, BlockSize);
    Inc(S, BlockSize);
    Inc(D, BlockSize);
    D^ := #13; Inc(D);
    D^ := #10; Inc(D);
    Dec(I, BlockSize);
  until I < BlockSize;
  Move(S^, D^, I);
  Inc(D, I);
  SetLength(Result, D - PChar(Result));
end;

function DeleteCR(const Value: String): String;
var
  S,D: PChar;
  I: Integer;
begin
  I := Length(Value);
  SetLength(Result, I);
  D := PChar(Result);
  S := PChar(Value);
  while I > 0 do
  begin
    if (S^ <> #10) and (S^ <> #13) then
    begin
      D^ := S^;
      Inc(D);
    end;
    Inc(S);
    Dec(I);
  end;
  SetLength(Result, D - PChar(Result));
end;

function InsertBlocks(const Value, BlockStart, BlockEnd: String; BlockSize: Integer): String;
var
  I,LS,LE: Integer;
  D,S: PChar;
begin
  if (BlockSize <= 0) or (Length(Value) <= BlockSize) then
  begin
    Result := Value;
    Exit;
  end;
  I := Length(Value);
  LS := Length(BlockStart);
  LE := Length(BlockEnd);
  SetLength(Result, I + (I div BlockSize + 1) * (LS + LE));
  S := PChar(Value);
  D := PChar(Result);
  repeat
    Move(PChar(BlockStart)^, D^, LS); Inc(D, LS);
    Move(S^, D^, BlockSize);          Inc(D, BlockSize);
    Move(PChar(BlockEnd)^, D^, LE);   Inc(D, LE);
    Dec(I, BlockSize);
    Inc(S, BlockSize);
  until I < BlockSize;
  if I > 0 then
  begin
    Move(PChar(BlockStart)^, D^, LS); Inc(D, LS);
    Move(S^, D^, I);                  Inc(D, I);
    Move(PChar(BlockEnd)^, D^, LE);   Inc(D, LE);
  end;
  SetLength(Result, D - PChar(Result));
end;

function RemoveBlocks(const Value, BlockStart, BlockEnd: String): String;
var
  LS,LE: Integer;
  S,D,L,K: PChar;
begin
  SetLength(Result, Length(Value));
  LS := Length(BlockStart);
  LE := Length(BlockEnd);
  D := PChar(Result);
  S := PChar(Value);
  L := S + Length(Value);

  repeat
    if S > L then Break;
    if LS > 0 then
    begin
      S := StrPos(S, PChar(BlockStart));
      if S = nil then Break;
      Inc(S, LS);
      if S > L then Break;
    end;
    K := StrPos(S, PChar(BlockEnd));
    if K = nil then K := L;
    Move(S^, D^, K - S);
    Inc(D, K - S);
    S := K + LE;
  until S >= L;
  SetLength(Result, D - PChar(Result));
end;

function GetShortClassName(Value: TClass): String;
var
  I: Integer;
begin
  Result := '';
  if Value = nil then Exit;
  Result := Value.ClassName;
  I := Pos('_', Result);
  if I > 0 then Delete(Result, 1, I);
end;

function RndXORBuffer(Seed: Integer; var Buffer; Size: Integer): Integer; assembler;
asm
      AND     EDX,EDX
      JZ      @@2
      AND     ECX,ECX
      JLE     @@2
      PUSH    EBX
@@1:  XOR     AL,[EDX]
      IMUL    EAX,EAX,134775813
      INC     EAX
      MOV     EBX,EAX
      SHR     EBX,24
      MOV     [EDX],BL
      INC     EDX
      DEC     ECX
      JNZ     @@1
      POP     EBX
@@2:
end;

// use Systemtime and XOR's with Performancecounter
function RndTimeSeed: Integer; assembler;
var
  SysTime: record
             Year: Word;
             Month: Word;
             DayOfWeek: Word;
             Day: Word;
             Hour: Word;
             Minute: Word;
             Second: Word;
             MilliSeconds: Word;
             Reserved: array [0..7] of Byte;
           end;
  Counter: record
             Lo,Hi: Integer;
           end;
asm
      LEA     EAX,SysTime
      PUSH    EAX
      CALL    GetSystemTime
      MOVZX   EAX,Word Ptr SysTime.Hour
      IMUL    EAX,60
      ADD     AX,SysTime.Minute
      IMUL    EAX,60
      MOVZX   EDX,Word Ptr SysTime.Second
      ADD     EAX,EDX
      IMUL    EAX,1000
      MOV     DX,SysTime.MilliSeconds
      ADD     EAX,EDX
      PUSH    EAX
      LEA     EAX,Counter
      PUSH    EAX
      CALL    QueryPerformanceCounter
      POP     EAX
      XOR     EAX,Counter.Lo
      XOR     EAX,Counter.Hi
end;

function CRC16(CRC: Word; Data: Pointer; DataSize: LongWord): Word; assembler;
asm
         AND    EDX,EDX
         JZ     @Exit
         AND    ECX,ECX
         JLE    @Exit
         PUSH   EBX
         PUSH   EDI
         XOR    EBX,EBX
         LEA    EDI,CS:[OFFSET @CRC16]
@Start:  MOV    BL,[EDX]
         XOR    BL,AL
         SHR    AX,8
         XOR    AX,[EDI + EBX * 2]
         INC    EDX
         DEC    ECX
         JNZ    @Start
         POP    EDI
         POP    EBX
@Exit:   RET
         NOP
@CRC16:  DW     00000h, 0C0C1h, 0C181h, 00140h, 0C301h, 003C0h, 00280h, 0C241h
         DW     0C601h, 006C0h, 00780h, 0C741h, 00500h, 0C5C1h, 0C481h, 00440h
         DW     0CC01h, 00CC0h, 00D80h, 0CD41h, 00F00h, 0CFC1h, 0CE81h, 00E40h
         DW     00A00h, 0CAC1h, 0CB81h, 00B40h, 0C901h, 009C0h, 00880h, 0C841h
         DW     0D801h, 018C0h, 01980h, 0D941h, 01B00h, 0DBC1h, 0DA81h, 01A40h
         DW     01E00h, 0DEC1h, 0DF81h, 01F40h, 0DD01h, 01DC0h, 01C80h, 0DC41h
         DW     01400h, 0D4C1h, 0D581h, 01540h, 0D701h, 017C0h, 01680h, 0D641h
         DW     0D201h, 012C0h, 01380h, 0D341h, 01100h, 0D1C1h, 0D081h, 01040h
         DW     0F001h, 030C0h, 03180h, 0F141h, 03300h, 0F3C1h, 0F281h, 03240h
         DW     03600h, 0F6C1h, 0F781h, 03740h, 0F501h, 035C0h, 03480h, 0F441h
         DW     03C00h, 0FCC1h, 0FD81h, 03D40h, 0FF01h, 03FC0h, 03E80h, 0FE41h
         DW     0FA01h, 03AC0h, 03B80h, 0FB41h, 03900h, 0F9C1h, 0F881h, 03840h
         DW     02800h, 0E8C1h, 0E981h, 02940h, 0EB01h, 02BC0h, 02A80h, 0EA41h
         DW     0EE01h, 02EC0h, 02F80h, 0EF41h, 02D00h, 0EDC1h, 0EC81h, 02C40h
         DW     0E401h, 024C0h, 02580h, 0E541h, 02700h, 0E7C1h, 0E681h, 02640h
         DW     02200h, 0E2C1h, 0E381h, 02340h, 0E101h, 021C0h, 02080h, 0E041h
         DW     0A001h, 060C0h, 06180h, 0A141h, 06300h, 0A3C1h, 0A281h, 06240h
         DW     06600h, 0A6C1h, 0A781h, 06740h, 0A501h, 065C0h, 06480h, 0A441h
         DW     06C00h, 0ACC1h, 0AD81h, 06D40h, 0AF01h, 06FC0h, 06E80h, 0AE41h
         DW     0AA01h, 06AC0h, 06B80h, 0AB41h, 06900h, 0A9C1h, 0A881h, 06840h
         DW     07800h, 0B8C1h, 0B981h, 07940h, 0BB01h, 07BC0h, 07A80h, 0BA41h
         DW     0BE01h, 07EC0h, 07F80h, 0BF41h, 07D00h, 0BDC1h, 0BC81h, 07C40h
         DW     0B401h, 074C0h, 07580h, 0B541h, 07700h, 0B7C1h, 0B681h, 07640h
         DW     07200h, 0B2C1h, 0B381h, 07340h, 0B101h, 071C0h, 07080h, 0B041h
         DW     05000h, 090C1h, 09181h, 05140h, 09301h, 053C0h, 05280h, 09241h
         DW     09601h, 056C0h, 05780h, 09741h, 05500h, 095C1h, 09481h, 05440h
         DW     09C01h, 05CC0h, 05D80h, 09D41h, 05F00h, 09FC1h, 09E81h, 05E40h
         DW     05A00h, 09AC1h, 09B81h, 05B40h, 09901h, 059C0h, 05880h, 09841h
         DW     08801h, 048C0h, 04980h, 08941h, 04B00h, 08BC1h, 08A81h, 04A40h
         DW     04E00h, 08EC1h, 08F81h, 04F40h, 08D01h, 04DC0h, 04C80h, 08C41h
         DW     04400h, 084C1h, 08581h, 04540h, 08701h, 047C0h, 04680h, 08641h
         DW     08201h, 042C0h, 04380h, 08341h, 04100h, 081C1h, 08081h, 04040h
end;

function CRC32(CRC: LongWord; Data: Pointer; DataSize: LongWord): LongWord; assembler;
asm
         AND    EDX,EDX
         JZ     @Exit
         AND    ECX,ECX
         JLE    @Exit
         PUSH   EBX
         PUSH   EDI
         XOR    EBX,EBX
         LEA    EDI,CS:[OFFSET @CRC32]
@Start:  MOV    BL,AL
         SHR    EAX,8
         XOR    BL,[EDX]
         XOR    EAX,[EDI + EBX * 4]
         INC    EDX
         DEC    ECX
         JNZ    @Start
         POP    EDI
         POP    EBX
@Exit:   RET
         DB 0, 0, 0, 0, 0 // Align Table
@CRC32:  DD 000000000h, 077073096h, 0EE0E612Ch, 0990951BAh
         DD 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
         DD 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h
         DD 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
         DD 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh
         DD 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
         DD 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh
         DD 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
         DD 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
         DD 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
         DD 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h
         DD 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
         DD 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h
         DD 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
         DD 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h
         DD 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
         DD 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah
         DD 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
         DD 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
         DD 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
         DD 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh
         DD 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
         DD 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch
         DD 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
         DD 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h
         DD 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
         DD 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h
         DD 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
         DD 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
         DD 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
         DD 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h
         DD 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
         DD 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah
         DD 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
         DD 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h
         DD 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
         DD 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh
         DD 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
         DD 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
         DD 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
         DD 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h
         DD 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
         DD 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h
         DD 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
         DD 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h
         DD 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
         DD 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h
         DD 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
         DD 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
         DD 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
         DD 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h
         DD 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
         DD 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh
         DD 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
         DD 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch
         DD 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
         DD 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h
         DD 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
         DD 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
         DD 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
         DD 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h
         DD 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
         DD 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h
         DD 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh
         DD 074726F50h, 0736E6F69h, 0706F4320h, 067697279h
         DD 028207468h, 031202963h, 020393939h, 048207962h
         DD 06E656761h, 064655220h, 06E616D64h, 06FBBA36Eh
end;

{a Random generated Testvector 256bit - 32 Bytes, it's used for Self Test}
function GetTestVector: PChar; assembler; register;
asm
         MOV   EAX,OFFSET @Vector
         RET
@Vector: DB    030h,044h,0EDh,06Eh,045h,0A4h,096h,0F5h
         DB    0F6h,035h,0A2h,0EBh,03Dh,01Ah,05Dh,0D6h
         DB    0CBh,01Dh,009h,082h,02Dh,0BDh,0F5h,060h
         DB    0C2h,0B8h,058h,0A1h,091h,0F9h,081h,0B1h
         DB    000h,000h,000h,000h,000h,000h,000h,000h
end;

{get the CPU Type from your system}
function GetCPUType: Integer; assembler;
asm
         PUSH   EBX
         PUSH   ECX
         PUSH   EDX
         MOV    EBX,ESP
         AND    ESP,0FFFFFFFCh
         PUSHFD
         PUSHFD
         POP    EAX
         MOV    ECX,EAX
         XOR    EAX,40000h
         PUSH   EAX
         POPFD
         PUSHFD
         POP    EAX
         XOR    EAX,ECX
         MOV    EAX,3
         JE     @Exit
         PUSHFD
         POP    EAX
         MOV    ECX,EAX
         XOR    EAX,200000h
         PUSH   EAX
         POPFD
         PUSHFD
         POP    EAX
         XOR    EAX,ECX
         MOV    EAX,4
         JE     @Exit
         PUSH   EBX
         MOV    EAX,1
         DB     0Fh,0A2h      //CPUID
         MOV    AL,AH
         AND    EAX,0Fh
         POP    EBX
@Exit:   POPFD
         MOV    ESP,EBX
         POP    EDX
         POP    ECX
         POP    EBX
end;

procedure ModuleUnload(Instance: Integer);
var // automaticaly deregistration
  I: Integer;
begin
  if FStrFMTs <> nil then
    for I := FStrFMTs.Count-1 downto 0 do
      if FindClassHInstance(TClass(FStrFMTs[I])) = Instance then
        FStrFMTs.Delete(I);
end;

initialization
  AddModuleUnloadProc(ModuleUnload);
  FCPUType := GetCPUType;
  if FCPUType > 3 then
  begin
    SwapInteger := BSwapInt;
    SwapIntegerBuffer := BSwapIntBuf;
  end else
  begin
    SwapInteger := SwapInt;
    SwapIntegerBuffer := SwapIntBuf;
  end;
  RegisterStringFormats([TStringFormat, TStringFormat_HEX, TStringFormat_HEXL,
      TStringFormat_MIME64, TStringFormat_UU, TStringFormat_XX]);
{this calculate a Checksum (CRC32) over the function CRC32 and the TestVector,
 if InitTestIsOk = False any modification from Testvector or CRC32() detected, :-) }
  InitTestIsOk  := CRC32(CRC32($29524828, PChar(@CRC32) + 41, 1076), GetTestVector, 32) = $848B5964;
finalization
  RemoveModuleUnloadProc(ModuleUnload);
  FStrFMTs.Free;
  FStrFMTs := nil;
end.
