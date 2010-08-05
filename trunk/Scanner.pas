unit Scanner;
{
Author: Wanderlan Santos dos Anjos, wanderlan.anjos@gmail.com
Date: jan-2010
License: <extlink http://www.opensource.org/licenses/bsd-license.php>BSD</extlink>
}
interface

type
  TTokenKind = (tkUndefined, tkIdentifier, tkStringConstant, tkCharConstant, tkIntegerConstant, tkRealConstant, tkConstantExpression,
                tkLabelIdentifier, tkTypeIdentifier, tkClassIdentifier, tkReservedWord, tkSpecialSymbol);
  TToken = class
    Lexeme       : string;
    Kind         : TTokenKind;
    RealValue    : Extended;
    IntegerValue : Int64;
  end;
  TSetChar = set of char;
  TScanner = class
  private
    Arq       : text;
    FToken    : TToken;
    LenLine   : integer;
    FInitTime : TDateTime;
    FSourceName, FEndComment, Line : string;
    procedure NextChar(C : TSetChar);
    procedure FindEndComment(EndComment : string);
    procedure SetFSourceName(const Value : string);
    procedure DoDirective(DollarInc : integer);
    procedure SkipBlank; inline;
    function TokenIn(S : string) : boolean; inline;
  protected
    FEndSource : boolean;
    FLineNumber, FTotalLines, First, FErrors, FMaxErrors, NestedIf : integer;
    function CharToTokenKind(N : char) : TTokenKind;
    function TokenKindToChar(T : TTokenKind) : char;
    function GetNonTerminalName(N : char) : string;
    procedure ScanChars(Chars: array of TSetChar; Tam : array of integer; Optional : boolean = false);
    procedure NextToken;
    procedure RecoverFromError(Expected, Found : string); virtual;
  public
    constructor Create(MaxErrors : integer = 10);
    destructor Destroy; override;
    procedure Error(Msg : string); virtual;
    procedure ErrorExpected(Expected, Found : string);
    procedure MatchToken(TokenExpected : string);
    procedure MatchTerminal(KindExpected : TTokenKind);
    property SourceName : string    read FSourceName write SetFSourceName;
    property LineNumber : integer   read FLineNumber;
    property TotalLines : integer   read FTotalLines;
    property ColNumber  : integer   read First;
    property Token      : TToken    read FToken;
    property EndSource  : boolean   read FEndSource;
    property Errors     : integer   read FErrors;
    property InitTime   : TDateTime read FInitTime;
  end;

implementation

uses
  SysUtils, StrUtils, Grammar;

const
  ReservedWords = '.and.array.as.asm.automated.begin.case.class.const.constructor.destructor.dispinterface.div.do.downto.else.end.except.exports.' +
    'file.finalization.finally.for.function.goto.if.implementation.in.inherited.initialization.inline.interface.is.label.library.mod.nil.' +
    'not.object.of.or.out.packed.private.procedure.program.property.protected.public.published.raise.record.repeat.resourcestring.set.shl.shr.' +
    'strict.then.threadvar.to.try.type.unit.until.uses.var.while.with.xor.';
  Kinds : array[TTokenKind] of string = ('Undefined', 'Identifier', 'String Constant', 'Char Constant', 'Integer Constant', 'Real Constant', 'Constant Expression',
     'Label Identifier', 'Type Identifier', 'Class Identifier', 'Reserved Word', 'Special Symbol');
  ConditionalSymbols : string = '.llvm.ver2010.mswindows.win32.cpu386.conditionalexpressions.';

constructor TScanner.Create(MaxErrors : integer = 10); begin
  FInitTime  := Now;
  FMaxErrors := MaxErrors;
  DecimalSeparator := '.';
end;

destructor TScanner.Destroy; begin
  writeln;
  if Errors <> 0 then writeln(Errors, ' error(s).');
  writeln(TotalLines, ' lines,', FormatDateTime(' s.z ', Now-InitTime), 'seconds, ', TotalLines/1000/((Now-InitTime)*24*60*60):0:1, ' klps.');
  inherited;
  FToken.Free;
end;

procedure TScanner.ScanChars(Chars : array of TSetChar; Tam : array of integer; Optional : boolean = false);
var
  I, T, Last : integer;
begin
  FToken.Lexeme := '';
  FToken.Kind   := tkUndefined;
  for I := 0 to high(Chars) do begin
    Last := First;
    T    := 1;
    while (Last <= LenLine) and (T <= Tam[I]) and (Line[Last] in Chars[I]) do begin
      inc(Last);
      inc(T);
    end;
    if Last > First then begin
      FToken.Lexeme := FToken.Lexeme + copy(Line, First, Last - First);
      First := Last;
    end
    else
      if Optional then exit;
  end;
end;

procedure TScanner.SetFSourceName(const Value : string); begin
  if FErrors >= FMaxErrors then Abort;
  if FileExists(SourceName) then close(Arq);
  FSourceName := Value;
  FLineNumber := 0;
  FEndSource  := false;
  LenLine     := 0;
  NestedIf    := 0;
  if FileExists(SourceName) then begin
    assign(Arq, SourceName);
    writeln(^M^J, SourceName);
    reset(Arq);
    First := 1;
    FToken := TToken.Create;
    NextToken;
  end
  else begin
    FEndSource := true;
    Error('Source file ''' + SourceName + ''' not found');
    Abort;
  end;
end;

procedure TScanner.NextChar(C : TSetChar); begin
  if (First < LenLine) and (Line[First + 1] in C) then begin
    FToken.Lexeme := copy(Line, First, 2);
    inc(First, 2);
  end
  else begin
    FToken.Lexeme := Line[First];
    inc(First);
  end;
  FToken.Kind := tkSpecialSymbol;
end;

procedure TScanner.DoDirective(DollarInc : integer);
var
  I : integer;
  L : string;
begin
  inc(First, DollarInc + 1);
  if Line[First] in ['A'..'Z', '_', 'a'..'z'] then begin
    ScanChars([['A'..'Z', 'a'..'z', '_', '0'..'9']], [255]);
    L := FToken.Lexeme;
    SkipBlank;
    ScanChars([['A'..'Z', 'a'..'z', '_', '0'..'9']], [255]);
    case AnsiIndexText(L, ['DEFINE', 'UNDEF', 'IFDEF', 'IFNDEF', 'IF']) of
      0 : if not TokenIn(ConditionalSymbols) then ConditionalSymbols := ConditionalSymbols + FToken.Lexeme + '.';
      1 : begin
        I := pos('.' + LowerCase(FToken.Lexeme) + '.', ConditionalSymbols);
        if I <> 0 then delete(ConditionalSymbols, I, length(FToken.Lexeme) + 1);
      end;
      2 : begin
        if not TokenIn(ConditionalSymbols) then FEndComment := 'ENDIF' + FEndComment;
        inc(NestedIf);
      end;
      3 : begin
        if TokenIn(ConditionalSymbols) then FEndComment := 'ENDIF' + FEndComment;
        inc(NestedIf);
      end;
      4 : inc(NestedIf);
    end;
    FindEndComment(FEndComment);
  end
  else begin
    Error('Invalid compiler directive ''' + Line[First] + '''');
    First := MAXINT;
  end;
end;

procedure TScanner.FindEndComment(EndComment : string);
var
  PosEnd : integer;
begin
  FEndComment := EndComment;
  if ((First + length(EndComment)) <= LenLine) and (Line[First + length(EndComment)] = '$') then
    DoDirective(length(EndComment))
  else begin
    if PosEx('{$IF', Line, First) <> 0 then inc(NestedIf);
    PosEnd := PosEx(EndComment, Line, First);
    if PosEnd <> 0 then begin // End comment in same line
      First := PosEnd + length(EndComment);
      if NestedIf > 0 then dec(NestedIf);
      if NestedIf = 0 then FEndComment := '';
    end
    else
      First := MAXINT;
  end;
end;

procedure TScanner.SkipBlank; begin
  while (First <= LenLine) and (Line[First] in [' ', #9]) do inc(First);
end;

function TScanner.TokenIn(S : string) : boolean; begin
  Result := pos('.' + LowerCase(FToken.Lexeme) + '.', S) <> 0
end;

procedure TScanner.NextToken;
var
  Str : string;
begin
  while not FEndSource do begin
    while First > LenLine do begin
      readln(Arq, Line);
      LenLine := length(Line);
      if EOF(Arq) and (LenLine = 0) then begin
        if FToken.Lexeme = 'End of Source' then
          FEndSource := true
        else
          FToken.Lexeme := 'End of Source';
        exit;
      end;
      inc(FLineNumber);
      inc(FTotalLines);
      First := 1;
    end;
    // End comment across many lines
    if FEndComment <> '' then begin
      FindEndComment(FEndComment);
      continue;
    end;
    case Line[First] of
      ' ', #9 : SkipBlank;
      'A'..'Z', '_', 'a'..'z' : begin // Identifiers
        ScanChars([['A'..'Z', 'a'..'z', '_', '0'..'9']], [255]);
        if (length(FToken.Lexeme) < 2) or not TokenIn(ReservedWords) then
          FToken.Kind := tkIdentifier
        else
          FToken.Kind := tkReservedWord;
        exit;
      end;
      ';', ',', '=', ')', '[', ']', '+', '-', '^', '@' : begin
        FToken.Lexeme := Line[First];
        FToken.Kind   := tkSpecialSymbol;
        inc(First);
        exit;
      end;
      '''': begin // strings
        Str := '';
        repeat
          inc(First);
          ScanChars([[#0..#255] - [''''], ['''']], [500, 1]);
          Str := Str + FToken.Lexeme;
          repeat
            ScanChars([['^'], ['@'..'Z']], [1, 1], true);
            if length(FToken.Lexeme) = 2 then
              Str := copy(Str, 1, length(Str)-1) + char(byte(FToken.Lexeme[2]) - ord('@')) + '''';
          until FToken.Lexeme = '';
          repeat
            ScanChars([['#'], ['0'..'9']], [1, 3], true);
            if length(FToken.Lexeme) >= 2 then
              Str := copy(Str, 1, length(Str)-1) + char(StrToIntDef(copy(FToken.Lexeme, 2, 100), 0)) + '''';
          until FToken.Lexeme = '';
        until Line[First] <> '''';
        FToken.Lexeme := copy(Str, 1, length(Str)-1);
        if length(FToken.Lexeme) = 1 then
          FToken.Kind := tkCharConstant
        else
          FToken.Kind := tkStringConstant;
        exit;
      end;
      '0'..'9': begin // Numbers
        ScanChars([['0'..'9'], ['.'], ['0'..'9'], ['E', 'e'], ['+', '-'], ['0'..'9']], [28, 1, 27, 1, 1, 3], true);
        FToken.Lexeme := UpperCase(FToken.Lexeme);
        if FToken.Lexeme[length(FToken.Lexeme)] in ['.', 'E', '+', '-'] then begin
          dec(First);
          SetLength(FToken.Lexeme, length(FToken.Lexeme)-1);
        end;
        if (pos('.', FToken.Lexeme) <> 0) or (pos('E', UpperCase(FToken.Lexeme)) <> 0) then
          FToken.Kind := tkRealConstant
        else
          if length(FToken.Lexeme) > 18 then
            FToken.Kind := tkRealConstant
          else
            FToken.Kind := tkIntegerConstant;
        if FToken.Kind = tkRealConstant then
          FToken.RealValue := StrToFloat(FToken.Lexeme)
        else
          FToken.IntegerValue := StrToInt64(FToken.Lexeme);
        exit;
      end;
      '(' :
        if (LenLine > First) and (Line[First + 1] = '*') then // Comment Style (*
          FindEndComment('*)')
        else begin
          FToken.Lexeme := '(';
          FToken.Kind   := tkSpecialSymbol;
          inc(First);
          exit
        end;
      '/' :
        if (LenLine > First) and (Line[First + 1] = '/') then // Comment Style //
          First := MAXINT
        else begin
          FToken.Lexeme := '/';
          FToken.Kind   := tkSpecialSymbol;
          inc(First);
          exit
        end;
      '{' : FindEndComment('}');
      '.' : begin NextChar(['.']); exit; end;
      '*' : begin NextChar(['*']); exit; end;
      '>',
      ':' : begin NextChar(['=']); exit; end;
      '<' : begin NextChar(['=', '>']); exit; end;
      '#' : begin
        ScanChars([['#'], ['0'..'9']], [1, 5]);
        if (FToken.Lexeme = '#') and (Line[First] = '$') then begin
          ScanChars([['$'], ['0'..'9', 'A'..'F', 'a'..'f']], [1, 4]);
          FToken.Lexeme := char(StrToInt(FToken.Lexeme));
        end
        else
          FToken.Lexeme := char(StrToInt(copy(FToken.Lexeme, 2, 5)));
        if length(FToken.Lexeme) = 1 then
          FToken.Kind := tkCharConstant
        else
          FToken.Kind := tkStringConstant;
        exit;
      end;
      '$' : begin // Hexadecimal
        ScanChars([['$'], ['0'..'9', 'A'..'F', 'a'..'f']], [1, 16]);
        FToken.Kind := tkIntegerConstant;
        FToken.IntegerValue := StrToInt64(FToken.Lexeme);
        exit;
      end;
    else
      Error('Invalid character ''' + Line[First] + ''' ($' + IntToHex(ord(Line[First]), 4) + ')');
      First := MAXINT;
    end;
  end;
end;

procedure TScanner.Error(Msg : string); begin
  writeln('[Error] ' + ExtractFileName(SourceName) + '('+ IntToStr(LineNumber) + ', ' + IntToStr(ColNumber) + '): ' + Msg);
  inc(FErrors);
  if FErrors >= FMaxErrors then FEndSource := true;
end;

function ReplaceSpecialChars(S : string) : string;
var
  I : integer;
begin
  Result := '';
  for I := 1 to length(S) do
    if S[I] >= ' ' then
      Result := Result + S[I]
    else
      Result := Result + '#' + IntToStr(byte(S[I]));
end;

procedure TScanner.ErrorExpected(Expected, Found : string); begin
  Error(Expected + ' expected but ''' + ReplaceSpecialChars(Found) + ''' found')
end;

procedure TScanner.RecoverFromError(Expected, Found : string); begin
  ErrorExpected(Expected, Found);
  while (FToken.Lexeme <> ';') and not EndSource do NextToken;
end;

procedure TScanner.MatchTerminal(KindExpected : TTokenKind); begin
  if KindExpected <> FToken.Kind then
    RecoverFromError(Kinds[KindExpected], FToken.Lexeme)
  else
    NextToken;
end;

procedure TScanner.MatchToken(TokenExpected : string); begin
  if TokenExpected <> UpperCase(FToken.Lexeme) then
    RecoverFromError('''' + TokenExpected + '''', FToken.Lexeme)
  else
    NextToken;
end;

function TScanner.CharToTokenKind(N : char) : TTokenKind; begin
  Result := TTokenKind(byte(N) - byte(pred(Ident)))
end;

function TScanner.TokenKindToChar(T : TTokenKind) : char; begin
  Result := char(byte(T) + byte(pred(Ident)))
end;

function TScanner.GetNonTerminalName(N : char): string; begin
  Result := Kinds[CharToTokenKind(N)]
end;

end.
