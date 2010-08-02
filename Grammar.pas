unit Grammar;

interface

const
  // Productions id
  Start        = #128; ParIdentList = #129; IdentList    = #130; UsesClause   = #131; ExportsList  = #132;
  DeclSection  = #133; VarDecl      = #134; VarList      = #135; VarInit      = #136; Type_        = #137;
  EnumList     = #138; CompoundStmt = #139; Statement    = #140; StmtList     = #141; Expression   = #142;
  ToOrDownto   = #143; WithList     = #144; IntSection   = #145; ImplSection  = #146; InitSection  = #147;
  TypeDecl     = #148; StringLength = #149; ArrayDim     = #150; ClassDecl    = #151; QualId       = #152;
  LabelAssign  = #153; LabelList    = #154; ClassHerit   = #155; FieldDecl    = #156; MethodDecl   = #157;
  FormalParams = #158; FormalList   = #159; FormalParam  = #160; ParamInit    = #161; ParamSpec    = #162;
  ConstDecl    = #163; ConstType    = #164; StaticDecl   = #165; OrdinalType  = #166; ArrayOfType  = #167;
  TypeId       = #168; ParamType    = #169; PropInterf   = #170; PropIndex    = #171; PropRead     = #172;
  PropWrite    = #173; PropStored   = #174; PropDefault  = #175; PropImplem   = #176; RelOp        = #177;
  MetId        = #178; AssignStmt   = #179; ElseBranch   = #180; ExprList     = #181; CaseList     = #182;
  EndCaseList  = #183; SetList      = #184; InterDecl    = #185; LabelId      = #186; SubRange     = #187;
  FileOf       = #188; ForStmt      = #189; PropParams   = #190; IdentDir     = #191; NameDir      = #192;
  GUID         = #193; ExceptFin    = #194; ExceptHand   = #195; ExceptType   = #196; ExceptList   = #197;
  InterfMet    = #198; InterDir     = #199; AbstractDir  = #200; FinSection   = #201; RaiseStmt    = #202;
  RaiseAt      = #203; PackedDecl   = #204; ObjHerit     = #205; ObjDecl      = #206; ForwardClass = #207;
  RsrcDecl     = #208; OfObject     = #209; Directives   = #210; ExternalDir  = #211; MetCall      = #212;
  DefProp      = #213; WarnDir      = #214; CallConv     = #215;

  // Other non terminals
  Ident = #240; StringConst = #241; CharConst = #242; IntConst = #243; RealConst = #244;
  // Grammar commands
  Require = #253; Mark = #254; Pop = #255;

  SimpleType = 'Type' + '|' + Ident + '|' + Expression + SubRange + '|INTEGER|' + '|BOOLEAN|' + '|BYTE|' + '|WORD|' + '|CARDINAL|' + '|LONGINT|' +
    '|INT64|' + '|UINT64|' + '|CHAR|' + '|WIDECHAR|' + '|WIDESTRING|' +'|LONGWORD|' + '|SHORTINT|' + '|SMALLINT|' +
    '|PCHAR|' + '|POINTER|' + '|REAL|' + '|SINGLE|' + '|DOUBLE|' + '|EXTENDED|' + '|CURRENCY|' + '|COMP|' +
    '|BYTEBOOL|' + '|WORDBOOL|'+ '|LONGBOOL|';

  Productions : array[Start..CallConv] of string = (
// Start
  '|PROGRAM|' + Ident + ParIdentList + ';' + UsesClause + InterDecl + Require + CompoundStmt  + '.' +
  '|UNIT|'    + Ident + ';' + Require + IntSection + Require + ImplSection + Require + InitSection + '.' +
  '|LIBRARY|' + Ident + ';' + UsesClause + DeclSection + Require + CompoundStmt  + '.' +
  '|PACKAGE|' + Ident + ';' + 'REQUIRES' + Ident + IdentList + 'CONTAINS' + Ident + IdentList + 'END.',
// ParIdentList
  '|(|' + Ident + IdentList + ')',
// IdentList
  '|,|' + Ident + IdentList,
// UsesClause
  '|USES|' + Ident + IdentList + ';',
// ExportsList
  '|,|' + Ident + FormalParams + PropIndex + NameDir + ExportsList,
// DeclSection
  'Declaration Section' +
  '|VAR|'         + Require + VarDecl + DeclSection +
  '|CONST|'       + Require + ConstDecl + DeclSection +
  '|TYPE|'        + Require + TypeDecl + DeclSection +
  '|LABEL|'       + Require + LabelId + LabelList + DeclSection +
  '|PROCEDURE|'   + Ident + MetId + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + ExternalDir + InterDecl + CompoundStmt + ';' + Mark + DeclSection +
  '|FUNCTION|'    + Ident + MetId + FormalParams + ':' + Ident + ';' + Directives + CallConv + AbstractDir + WarnDir + ExternalDir + InterDecl + CompoundStmt + ';' + Mark + DeclSection +
  '|CONSTRUCTOR|' + Ident + MetId + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + InterDecl + Require + CompoundStmt + ';' + DeclSection +
  '|DESTRUCTOR|'  + Ident + MetId + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + InterDecl + Require + CompoundStmt + ';' + DeclSection +
  '|THREADVAR|'   + Require + VarDecl + DeclSection +
  '|EXPORTS|'     + Ident + FormalParams + PropIndex + NameDir + ExportsList + DeclSection +
  '|RESOURCESTRING|' + Require + RsrcDecl + DeclSection,
// VarDecl
  '|' + Ident + '|' + VarList + ':' + Require + Type_ + VarInit + ';' + Mark + VarDecl,
// VarList
  '|,|' + Ident + VarList,
// VarInit
  '|=|' + Require + Expression +
  '|ABSOLUTE|' + Ident,
// Type_
  SimpleType +
  '|ARRAY|'  + ArrayDim + 'OF' + Require + Type_ +
  '|STRING|' + StringLength +
  '|'+ IntConst + '|' + Require + SubRange +
  '|'+ CharConst + '|' + Require + SubRange +
  '|(|' + Ident + EnumList + ')' +
  '|+|' + Ident + Expression + Require + SubRange +
  '|-|' + Ident + Expression + Require + SubRange +
  '|^|' + Ident +
  '|RECORD|' + FieldDecl + 'END' +
  '|CLASS|' + ForwardClass + ClassHerit + ForwardClass + FieldDecl + MethodDecl + ClassDecl + 'END' +
  '|OBJECT|' + ObjHerit + FieldDecl + MethodDecl + ObjDecl + 'END' +
  '|INTERFACE|' + ForwardClass + ParIdentList + GUID + InterfMet + 'END' +
  '|SET|' + 'OF' + Require + OrdinalType +
  '|PROCEDURE|' + FormalParams + OfObject + Directives + CallConv + AbstractDir + WarnDir +
  '|FUNCTION|' + FormalParams + ':' + Ident + OfObject + Directives + CallConv + AbstractDir + WarnDir + 
  '|PACKED|' + PackedDecl +
  '|FILE|'   + FileOf +
  '|TEXT|'   +
  '|TYPE|'   + Ident,
// EnumList
  '|,|' + Ident + EnumList,
// CompoundStmt
  '|BEGIN|' + Statement + StmtList + 'END',
// Statement
  '|' + Ident + '|' + LabelAssign + AssignStmt + Mark +
  '|BEGIN|' + Statement + StmtList + 'END' +
  '|IF|' + Require + Expression + 'THEN' + Statement + ElseBranch +
  '|REPEAT|' + Statement + StmtList + 'UNTIL' + Require + Expression +
  '|WHILE|' + Require + Expression + 'DO' + Statement +
  '|FOR|' + Ident + QualId + Require + ForStmt + 'DO' + Statement +
  '|WITH|' + Ident + QualId + WithList + 'DO' + Statement +
  '|CASE|' + Require + Expression + 'OF' + Require + Expression + SetList + ':' + Statement + CaseList + Mark +
  '|TRY|' + Statement + StmtList + Require + ExceptFin +
  '|GOTO|' + Require + LabelId +
  '|INHERITED|' + MetCall +
  '|RAISE|' + RaiseStmt +
  '|' + IntConst + '|' + ':' + Statement +
  '|ASM|' + (*AsmStatement +*) 'END',
// StmtList
  '|;|' + Statement + StmtList,
// Expression
  'Expression' +
  '|' + Ident + '|' + QualId + RelOp + Expression +
  '|' + IntConst + '|' + RelOp + Expression +
  '|' + StringConst + '|' + RelOp + Expression +
  '|' + CharConst + '|' + RelOp + Expression +
  '|' + RealConst + '|' + RelOp + Expression +
  '|+|' + Expression +
  '|-|' + Expression +
  '|NOT|' + Expression +
  '|(|' + Expression + ExprList + ')' + RelOp + Expression +
  '|NIL|' +
  '|@|' + Expression +
  '|[|' + Expression + SetList + ']' + Expression,
// ToOrDownto
  '|TO||DOWNTO|',
// WithList
  '|,|' + Ident + QualId + WithList,
// IntSection
  '|INTERFACE|' + UsesClause + InterDecl,
// ImplSection
  '|IMPLEMENTATION|'+ UsesClause + DeclSection,
// InitSection
  '|BEGIN|' + Statement + StmtList + 'END' +
  '|INITIALIZATION|' + Statement + StmtList + FinSection +
  '|END|',
// TypeDecl
  '|' + Ident + '|' + '=' + Require + Type_ + ';' + Mark + TypeDecl,
// StringLength
  '|[|' + Require + IntConst + ']',
// ArrayDim
  '|[|' + Require + Expression + SetList + ']',
// ClassDecl
  '|PRIVATE|' + FieldDecl + MethodDecl + ClassDecl +
  '|PROTECTED|' + FieldDecl + MethodDecl + ClassDecl +
  '|PUBLIC|' + FieldDecl + MethodDecl + ClassDecl +
  '|PUBLISHED|' + FieldDecl + MethodDecl + ClassDecl +
  '|CLASS|' + StaticDecl + FieldDecl + MethodDecl + ClassDecl +
  '|AUTOMATED|' + FieldDecl + MethodDecl + ClassDecl,
// QualId
  '|.|' + Ident + QualId +
  '|(|' + Expression + ExprList + ')' + QualId +
  '|[|' + Require + Expression + ExprList + ']' + QualId,
// LabelAssign
  '|.|' + Ident + QualId +
  '|(|' + Expression + ExprList + ')' + QualId +
  '|[|' + Require + Expression + ExprList + ']' + QualId +
  '|:|' + Statement + Pop,
// LabelList
  '|,|' + Require + LabelId + LabelList,
// ClassHerit
  '|(|' + Ident + IdentList + ')' +
  '|OF|' + Ident + Pop,
// FieldDecl
  '|' + Ident + '|' + VarList + ':' + Require + Type_ + ';' + FieldDecl,
// MethodDecl
  '|PROCEDURE|'   + Ident + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + MethodDecl +
  '|FUNCTION|'    + Ident + FormalParams + ':' + Ident + ';' + Directives + CallConv + AbstractDir + WarnDir + MethodDecl +
  '|CONSTRUCTOR|' + Ident + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + MethodDecl +
  '|DESTRUCTOR|'  + Ident + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + MethodDecl +
  '|PROPERTY|'    + Ident + PropParams + PropInterf + PropIndex + PropRead + PropWrite + PropStored + PropDefault + PropImplem + ';' + DefProp + MethodDecl,
// FormalParams
  '|(|' + FormalParam + FormalList + ')',
// FormalList
  '|;|' + FormalParam + FormalList,
// FormalParam
  '|' + Ident + '|' + IdentList + Require + ParamSpec + ParamInit +
  '|VAR|' + Ident + IdentList + ParamSpec +
  '|CONST|' + Ident + IdentList + ParamSpec + ParamInit +
  '|OUT|' + Ident + IdentList + ParamSpec,
// ParamInit
  '|=|' + Expression,
// ParamSpec
  '|:|' + Require + ParamType,
// ConstDecl
  '|' + Ident + '|' + ConstType + '=' + Require + Expression + ';' + ConstDecl,
// ConstType
  '|:|' + Require + Type_,
// StaticDecl
  '|VAR|' + Require + FieldDecl +
  '|PROCEDURE|' + Ident + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir +
  '|FUNCTION|'  + Ident + FormalParams + ':' + Ident + ';' + Directives + CallConv + AbstractDir + WarnDir + 
  '|PROPERTY|'  + Ident + PropParams + PropInterf + PropIndex + PropRead + PropWrite + PropStored + PropDefault + PropImplem + ';' + DefProp,
// OrdinalType
  '|' + Ident + '|' + SubRange +
  '|' + IntConst + '|' + Require + SubRange +
  '|' + CharConst + '|' + Require + SubRange +
  '|(|' + Ident + EnumList + ')',
// ArrayOfType
  SimpleType +
  '|CONST|',
// TypeId
  SimpleType,
// ParamType
  SimpleType +
  '|STRING||FILE||TEXT|' +
  '|ARRAY|' + 'OF' + Require + ArrayOfType,
// PropInterf
  '|:|' + TypeId,
// PropIndex
  '|INDEX|' + IntConst,
// PropRead
  '|READ|' + Ident,
// PropWrite
  '|WRITE|' + Ident,
// PropStored
  '|STORED|' + Ident,
// PropDefault
  '|DEFAULT|' + Expression +
  '|NODEFAULT|',
// PropImplem
  '|IMPLEMENTS|' + Ident + IdentList,
// RelOp
  '|>||<||>=||<=||<>||=||IN||IS||AS|' +
  '|+||-||AND||OR|' +
  '|*||/||DIV||MOD|',
// MetId
  '|.|' + Ident,
// AssignStmt
  '|:=|' + Require + Expression,
// ElseBranch
  '|ELSE|' + Statement,
// ExprList
  '|,|' + Require + Expression + SetList,
// CaseList
  '|;|' + EndCaseList + Require + Expression + SetList + ':' + Statement + CaseList +
  '|ELSE|' + Statement + StmtList + 'END' +
  '|END|',
// EndCaseList
  '|ELSE|' + Statement + StmtList + 'END' + Pop +
  '|END|' + Pop,
// SetList
  '|,|' + Require + Expression + SetList +
  '|..|' + Require + Expression + ExprList,
// InterDecl
  'Declaration Section' +
  '|VAR|' + Require + VarDecl + InterDecl +
  '|CONST|' + Require + ConstDecl + InterDecl +
  '|TYPE|' + Require + TypeDecl + InterDecl +
  '|LABEL|' + Require + LabelId + LabelList + InterDecl +
  '|PROCEDURE|' + Ident + FormalParams + ';' + Directives + CallConv + AbstractDir + WarnDir + ExternalDir + InterDecl + Require + CompoundStmt + ';' + InterDecl +
  '|FUNCTION|'  + Ident + FormalParams + ':' + Ident + ';' + Directives + CallConv + AbstractDir + WarnDir + ExternalDir + InterDecl + Require + CompoundStmt + ';' + InterDecl +
  '|RESOURCESTRING|' + Require + RsrcDecl + DeclSection,
// LabelId
  '|' + Ident + '|' +
  '|' + IntConst + '|',
// SubRange
  '|..|' + Require + Expression, //Ordinal,
// FileOf
  '|OF|' + Require + TypeId,
// ForStmt
  '|:=|' + Require + Expression + Require + ToOrDownto + Require + Expression +
  '|IN|' + Require + Expression,
// PropParams
  '|[|' + Require + FormalParam + FormalList + ']',
// IdentDir
  '|' + StringConst + '|' +
  '|' + Ident + '|' +
  '|' + CharConst + '|',
// NameDir
  '|NAME|' + Require + IdentDir,
// GUID
  '|[|' + IdentDir + ']',
// ExceptFin
  '|EXCEPT|' + ExceptHand + Statement + StmtList + Mark + 
  '|FINALLY|' + Statement + StmtList + 'END',
// ExceptHand
  '|ON|' + Ident + ExceptType + 'DO' + Statement + ExceptList + EndCaseList + Pop,
// ExceptType
  '|:|' + Ident,
// ExceptList
  '|;|' + ExceptHand,
// InterfMet
  '|PROCEDURE|' + Ident + FormalParams + ';' + InterDir + InterfMet +
  '|FUNCTION|'  + Ident + FormalParams + ':' + Ident + ';' + InterDir + InterfMet +
  '|PROPERTY|'  + Ident + PropParams + PropInterf + PropIndex + PropRead + PropWrite + PropDefault + ';' + DefProp + InterfMet,
// InterDir
  '|CDECL|;' + '|SAFECALL|;' + '|STDCALL|;' + '|REGISTER|;' + '|PASCAL|;',
// AbstractDir
  '|ABSTRACT|;',
// FinSection
  '|FINALIZATION|' + Statement + StmtList + 'END',
// RaiseStmt
  '|' + Ident + '|' + QualId + RaiseAt,
// RaiseAt
  '|AT|' + Require + Expression,
// PackedDecl
  '|ARRAY|' + ArrayDim + 'OF' + Require + Type_ +
  '|RECORD|' + FieldDecl + 'END' +
  '|CLASS|' + ForwardClass + ClassHerit + ForwardClass + FieldDecl + MethodDecl + ClassDecl + 'END' + Mark + // Forwardclass
  '|OBJECT|' + ObjHerit + FieldDecl + MethodDecl + ObjDecl + 'END' +
  '|SET|' + 'OF' + Require + OrdinalType +
  '|FILE|' + FileOf,
// ObjHerit
  '|(|' + Ident + ')',
// ObjDecl
  '|PRIVATE|' + FieldDecl + MethodDecl + ObjDecl +
  '|PROTECTED|' + FieldDecl + MethodDecl + ObjDecl +
  '|PUBLIC|' + FieldDecl + MethodDecl + ObjDecl,
// ForwardClass
  '|;|' + Pop +
  '|OF|' + Ident + ';' + Pop,
// RsrcDecl
  '|' + Ident + '|' + '=' + StringConst + ';' + RsrcDecl,
// OfObject
  '|OF|' + 'OBJECT',
// Directives
  '|REINTRODUCE|;' + Directives + '|OVERLOAD|;' + Directives + '|VIRTUAL|;' + Mark + '|OVERRIDE|;' + Mark +
  '|MESSAGE|;' + LabelId + '|DYNAMIC|;' + Mark,
// ExternalDir
  '|EXTERNAL|' + IdentDir + PropIndex + NameDir + ';' + Pop,
// MetCall
  '|' + Ident + '|' + QualId,
// DefProp
  '|DEFAULT|;',
// WarnDir
  '|PLATFORM|;' + Mark + '|DEPRECATED|;' + Mark + '|LIBRARY|;' + Mark,
// CallConv
  '|FORWARD|' +  Pop +
  '|CDECL|;'+ Mark + '|SAFECALL|;' + Mark + '|STDCALL|;' + Mark + '|REGISTER|;' + Mark + '|PASCAL|;' + Mark + '|INLINE|;' + Mark +
  '|FAR|;' + Mark + '|NEAR|;' + Mark + '|EXPORT|;' + Mark // Deprecateds
  );

implementation

end.
