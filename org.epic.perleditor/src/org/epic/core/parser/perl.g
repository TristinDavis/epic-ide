header
{
// This source file was generated by ANTLR. Do not edit manually!
package org.epic.core.parser;
}

class PerlLexer extends Lexer("org.epic.core.parser.PerlLexerBase");
options
{
	k = 4;
	charVocabulary = '\0'..'\uFFFF';
	importVocab = shared;
	exportVocab = Perl;
}

WS: (' ' | '\t' | NEWLINE)+;

COMMENT: '#' (NOT_NEWLINE)* (NEWLINE! | '\uFFFF'!);

SEMI
	: ';'
	{
		format = glob = afterArrow = afterDArrow = false;
		qmarkRegexp = slashRegexp = true;
		$setToken(createOperatorToken(PerlTokenTypes.SEMI, ";"));
	}
	;

OPEN_CURLY
	: '{'
	{
		$setToken(createCurlyToken(PerlTokenTypes.OPEN_CURLY, "{")); pc++;
		proto = glob = afterSub = false;
		qmarkRegexp = slashRegexp = true;
	};

CLOSE_CURLY
	: '}'
	{
		pc--; $setToken(createCurlyToken(PerlTokenTypes.CLOSE_CURLY, "}"));
		qmarkRegexp = slashRegexp = format = glob = false;
	};

OPEN_BQUOTE: '`'  { getParent().expectStringEnd('`'); };
OPEN_SQUOTE: '\'' {	getParent().expectStringEnd('\''); };
OPEN_DQUOTE: '"'  { getParent().expectStringEnd('"'); };

MAYBE_SPECIAL_VAR
	: { !proto }? (
	("**=")
	=> "**=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_MULMULEQ, "**=")); }
	| ("**")
	=> "**" { $setToken(createOperatorToken(PerlTokenTypes.OPER_MULMUL, "**")); }
	| ("*=")
	=> "*=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_MULEQ, "*=")); }
	| (VAR)
	=> VAR { $setType(PerlTokenTypes.VAR); }
	| (SPECIAL_VAR)
	=> SPECIAL_VAR { $setType(PerlTokenTypes.SPECIAL_VAR); glob = false; }
	| ('*')
	=> '*' { $setToken(createOperatorToken(PerlTokenTypes.OPER_MUL, "*")); }
	| ("%=")
	=> "%=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_MODEQ, "%=")); }
	| ('%')
	=> '%' { $setToken(createOperatorToken(PerlTokenTypes.OPER_MOD, "%")); }
	| (VAR_START) // incomplete variable
	=> VAR_START { $setType(PerlTokenTypes.VAR); }
	);

protected SPECIAL_VAR
	// see English.pm for the *? operators
	: (
	  "*^A" | "*^C" | "*^D" | "*^E" | "*^F" | "*^I" | "*^L" | "*^N"
	| "*^O" | "*^P" | "*^R" | "*^S" | "*^T" | "*^V" | "*^W" | "*^X"
	| "*/" |  "*?" | "*%" | "*@" | "*_" | "*-" | "*+" | "*." | "*|" | "*,"
	| "*;" | "*~" | "*:" | "*^" | "*<" | "*>" | "*(" | "*)" /* | "*$" TODO, watch out: 5*$x */
 	| "*\"" | "*\\"

	| "$$m" | "$$s"
	| "$^A" | "$^C" | "$^D" | "$^E" | "$^F" | "$^H" | "$^I" | "$^L" | "$^M"
	| "$^N" | "$^O" | "$^P" | "$^R" | "$^S" | "$^T" | "$^V" | "$^W" | "$^X"
	| "$/" | "$?" | "$%" | "$@" | "$_" | "$-" | "$+" | "$." | "$|" | "$!"
	| "$;" | "$~" | "$$" | "$`" | "$'" | "$<" | "$>" | "$(" | "$)" | "$,"
	| "$[" | "$]" | "$:" | "$*" | "$#" | "$=" | "$^" | "$&"
	| "$\"" | "$\\"

	| "@+" | "@-" | "@_" | "@$"
	
	| "%!" | "%@" | "%^H"
	);

protected VAR
	: { !proto }? VAR_START (ID | CURLY | '@' | '\uFFFF'!)
	{ glob = qmarkRegexp = slashRegexp = false; };

protected VAR_START
	: ('@' | '$' | '%' /* | '*' TODO, but think of $x*5 */)
	('@' | '$' | '%' | '*' | '#' /* | ' ' TODO, but think of $x % $y */)*
	;

protected CURLY
	: '{'
	( CURLY | NEWLINE | ~('}' | '\uFFFF'))*
	('}' | '\uFFFF'!)
	;

OPER_AND:    "&&" { $setToken(createOperatorToken(PerlTokenTypes.OPER_AND, "&&")); };
OPER_OR:     "||" { $setToken(createOperatorToken(PerlTokenTypes.OPER_OR, "||")); };
OPER_LTEQ:   "<=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_LTEQ, "<=")); };
OPER_GTEQ:   ">=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_GTEQ, ">=")); };

OPER_ANDANDEQ: "&&=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_ANDANDEQ, "&&=")); };
OPER_OROREQ:   "||=" { $setToken(createOperatorToken(PerlTokenTypes.OPER_OROREQ, "||=")); };

PROTO
	: { proto }?
	('$' | '@' | '%' | '*' | ';' | '\\' | '&' | '_' | WS)+
	{ proto = false; }
	;

OPER_S: "-s" { $setToken(createOperatorToken(PerlTokenTypes.OPER_S, "-s")); };

OPER_SLASHSLASH
	: { !slashRegexp }? "//"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_SLASHSLASH, "//"));
	};

OPER_SLASHSLASHEQ
	: { !slashRegexp }? "//="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_SLASHSLASHEQ, "//="));
	};

OPEN_SLASH
	: '/'
	{
		if (slashRegexp)
		{
    		getParent().expectStringSuffix(); // second
    		getParent().expectStringEnd('/'); // first
    		slashRegexp = qmarkRegexp = false;
		}
		else
		{
			$setToken(createOperatorToken(PerlTokenTypes.OPER_DIV, "/"));
		}
	};

protected OPER_QMARK: ;

OPEN_QMARK
	: '?'
	{
		if (qmarkRegexp)
		{
    		getParent().expectStringSuffix(); // second
    		getParent().expectStringEnd('?'); // first
    		slashRegexp = qmarkRegexp = false;
		}
		else
		{
			$setToken(createOperatorToken(PerlTokenTypes.OPER_QMARK, "?"));
		}
	};

SUBST_OR_MATCH_OR_WORD // this disambiguation rule disfavours EXPRs too much :-(
	: { !afterArrow }? ((SUBST_OR_MATCH_OPER | 'x') (('A'..'Z' | 'a'..'z' | '0'..'9') | ((WS_CHAR)* "=>")))
	=> { notOper = true; } t1:WORD { $setToken(t1); }
	| { !afterArrow && !afterSub }? (("tr" | 's' | 'y') ~'}')
	=> SUBST_EXPR { $setType(PerlTokenTypes.SUBST_EXPR); }
	| { !afterArrow || afterDArrow }? (("qq" | "qx" | "qw" | "qr" | 'm' | 'q') ~('a'..'z' | '0'..'9' | '_' | '}' | '\r' | '\n' | ' '))
	=> MATCH_EXPR { $setType(PerlTokenTypes.MATCH_EXPR); }
	| (NUMBER)
	=> n:NUMBER { $setToken(n); }
	| (':' ('\uFFFF'! | ~':'))
	=> ':'
	{
		glob = false;
		$setToken(createOperatorToken(PerlTokenTypes.OPER_COLON, ":"));
	}
	| t3:WORD { $setToken(t3); }
	;

protected SUBST_EXPR
	: ("tr" | 's' | 'y')
	{
		getParent().expectSubstExpr();
		slashRegexp = qmarkRegexp = false;
	}; 

protected MATCH_EXPR
	: ("qq" | "qx" | "qw" | "qr" | 'm' | 'q')
	{
		getParent().expectStringSuffix(); // second
		getParent().expectString(); // first
		slashRegexp = qmarkRegexp = false;
	};

OPER_DARROW
	: "=>"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_DARROW, "=>"));
		afterArrow = afterDArrow = true;
	};

OPER_ARROW
	: "->"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_ARROW, "->"));
		qmarkRegexp = slashRegexp = false;
		afterArrow = true;
	};

OPER_DOUBLEEQ
	: "=="
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_DOUBLEEQ, "==")); };

OPER_NOTEQ
	: "!="
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_NOTEQ, "!=")); };

OPER_EQMATCH
	: "=~"
	{ afterArrow = afterDArrow = false; $setToken(createOperatorToken(PerlTokenTypes.OPER_EQMATCH, "=~")); };

OPER_SMARTMATCH
	: "~~"
	{ afterArrow = afterDArrow = false; $setToken(createOperatorToken(PerlTokenTypes.OPER_SMARTMATCH, "~~")); };

OPER_EQNOTMATCH
	: "!~"
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_EQNOTMATCH, "!~")); };

OPER_MINUSMINUS
	: "--"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_MINUSMINUS, "--"));
		qmarkRegexp = false;
	};

OPER_MINUSEQ
	: "-="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_PLUSPLUS, "-="));
		qmarkRegexp = false;
	};

OPER_PLUSPLUS
	: "++"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_PLUSPLUS, "++"));
		qmarkRegexp = false;
	};

OPER_PLUSEQ
	: "+="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_PLUSPLUS, "+="));
		qmarkRegexp = false;
	};

OPER_ANDEQ
	: "&="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_OREQ, "&="));
		qmarkRegexp = false;
	};

OPER_OREQ
	: "|="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_OREQ, "|="));
		qmarkRegexp = false;
	};

OPER_XOREQ
	: "^="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_XOREQ, "^="));
		qmarkRegexp = false;
	};

OPER_DIVEQ
	: { !slashRegexp }? "/="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_DIVEQ, "/="));
		qmarkRegexp = false;
	};

OPER_COMMA
	: ','
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_COMMA, ","));
		afterArrow = afterDArrow = false;
	};

OPER_EQ
	: { !format }? '='
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_EQ, "="));
		glob = true;
	};

OPER_DIV
	: '/'
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_DIV, "/")); };

OPER_PLUS
	: '+'
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_PLUS, "+")); };

OPER_MINUS
	: '-'
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_MINUS, "-")); };

OPER_DOTDOT
	: ".."
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_DOTDOT, "..")); };

OPER_DOT
	: '.'
	{ afterArrow = afterDArrow = false; $setToken(createOperatorToken(PerlTokenTypes.OPER_DOT, ".")); };

OPER_NOT
	: '!'
	{ slashRegexp = true; $setToken(createOperatorToken(PerlTokenTypes.OPER_NOT, "!")); };

OPER_BSLASH
	: '\\'
	{ $setToken(createOperatorToken(PerlTokenTypes.OPER_BSLASH, "\\")); };

OPEN_PAREN
	: '('
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPEN_PAREN, "("));
		if (afterSub) { afterSub = false; proto = true; }
		format = false;
		glob = qmarkRegexp = slashRegexp = true;
	};

CLOSE_PAREN
	: ')'
	{
		$setToken(createOperatorToken(PerlTokenTypes.CLOSE_PAREN, ")"));
		glob = qmarkRegexp = slashRegexp = false;
	};

OPEN_BRACKET
	: '['
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPEN_BRACKET, "["));
		format = false;
		glob = qmarkRegexp = slashRegexp = true;
	};

CLOSE_BRACKET
	: ']'
	{
		$setToken(createOperatorToken(PerlTokenTypes.CLOSE_BRACKET, "]"));
		glob = qmarkRegexp = slashRegexp = false;
	};

FORMAT_STMT
	: { format }? "="
	{
		format = false;
		getParent().expectFormatEnd();
	};

protected VAR_WITH_CURLY
	: (VAR (WS)? '{')
	=> VAR (WS)? { getParent().expectString(); }
	| (VAR)
	=> VAR;

PROC_REF
	: '&' ID
	{ qmarkRegexp = slashRegexp = false; };

OPER_LSHIFT_OR_HEREDOC
	: (OPEN_HEREDOC) //("<<" (WS)?  ('"' | '\'' | '`' | 'A'..'Z'))
	=> OPEN_HEREDOC
	   { $setType(PerlTokenTypes.OPEN_HEREDOC); }
	| ("<<=")
	=> OPER_LSHIFTEQ
	   { $setToken(createOperatorToken(PerlTokenTypes.OPER_LSHIFTEQ, "<<=")); }	
	| ("<<" (WS)? ~('"' | '\'' | '`' | 'A'..'Z'))
	=> OPER_LSHIFT
	   { $setToken(createOperatorToken(PerlTokenTypes.OPER_LSHIFT, "<<")); }
	;

protected OPER_LSHIFT: "<<";
protected OPER_LSHIFTEQ: "<<=";

protected OPEN_HEREDOC
	:
	(
		("<<" (WS)? '"')
		=> "<<" (WS!)? '"'! ("\\\"" | ~('"' | '\n' | '\r' | '\uFFFF'))*
		| ("<<" (WS)? "'")
		=> "<<" (WS!)? "'"! ("\\'"  | ~('\'' | '\n' | '\r' | '\uFFFF'))*
		| ("<<" (WS)? '`')
		=> "<<" (WS!)? '`'! ("\\`"  | ~('`' | '\n' | '\r' | '\uFFFF'))*
		| ("<<" (WS)? ('A'..'Z'|'a'..'z'|'_'))
		=> "<<" ('A'..'Z'|'a'..'z'|'_')+
	)
	(NOT_NEWLINE!)*
	{ if (LA(1) != EOF_CHAR) getParent().expectHereDocEnd($getText); }
	(NEWLINE | '\uFFFF'!) // tolerate "print <<B" at the end of file...
	// TODO: proper handling of here-docs with quoted identifiers,
	// see man perlop
	;

GLOB
	: { glob }?
	'<' (~('<' | '>' | '\n' | '\r' | '\uFFFF'))* ('>' | '\uFFFF'!)
	;

OPER_RSHIFT
	: ">>"
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_RSHIFT, ">>"));
		qmarkRegexp = slashRegexp = false;
	}
	;

OPER_RSHIFTEQ
	: ">>="
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_RSHIFTEQ, ">>="));
		qmarkRegexp = slashRegexp = false;
	}
	;

OPER_GT
	: '>'
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_GT, ">"));
		qmarkRegexp = slashRegexp = false;
	}
	;

OPER_LT
	: { !glob }?
	'<'
	{
		$setToken(createOperatorToken(PerlTokenTypes.OPER_LT, "<"));
		qmarkRegexp = slashRegexp = false;
	}
	;

OPEN_POD
	: { getColumn() == 1 }?
	'=' ID (NOT_NEWLINE)* (NEWLINE! | '\uFFFF'!)
	{ getParent().expectPODEnd(); }
	;

protected NUMBER
	: ("0x" ('0'..'9' | 'A'..'F' | 'a'..'f' | '_')+)
	| ("0b" ('0' | '1' | '_')+)
	| ('0'..'9') ('0'..'9' | '_')*
	{
		slashRegexp = qmarkRegexp = glob = afterArrow = afterDArrow = false;
		$setType(PerlTokenTypes.NUMBER);
	};

protected WORD
	: ID
	{
		String str = $getText;
		
		if ("use".equals(str)) $setType(PerlTokenTypes.KEYWORD_USE);
		else if ("sub".equals(str)) { afterSub = true; $setType(PerlTokenTypes.KEYWORD_SUB); }
		else if ("package".equals(str)) { $setType(PerlTokenTypes.KEYWORD_PACKAGE); }
		else if ("format".equals(str) && !afterSub) { format = true; $setType(PerlTokenTypes.KEYWORD_FORMAT); }
		else if ("__END__".equals(str)) { $setType(Token.EOF_TYPE); }
		else if ("__DATA__".equals(str)) { $setType(Token.EOF_TYPE); }
		else if (!afterSub)
		{
			if (KEYWORDS1.contains(str))
    		{
    			if ("while".equals(str)) glob = true;
    			$setType(PerlTokenTypes.KEYWORD1);
    		}
    		else if (KEYWORDS2.contains(str))
    		{
    			glob = str.equals("unlink");
    			slashRegexp = false; // actually becomes true, see below!
    			$setType(PerlTokenTypes.KEYWORD2);
    		}
    		else if (OPERATORS.contains(str) && !afterArrow && !notOper)
    		{
    			glob = false;
    			$setToken(createOperatorToken(PerlTokenTypes.OPER_OTHER, str));
    		}
		}
		else glob = false;
		
		slashRegexp = !(afterArrow || slashRegexp);
		qmarkRegexp = afterArrow = notOper = false;
	}
	;

protected ID
	: { afterColon = false; }
	(
	{
		// keep going if we have "::", break on ":"
		// there must be a better way to implement it X-(
		if (LA(1) == ':') 
		{
			if (!afterColon && LA(2) != ':') break;
			else afterColon = true;
		}
		else afterColon = false;
	} WORD_CHAR)+
	;

protected WORD_CHAR
	: ('A'..'Z' | 'a'..'z' | '0'..'9' | '_' | ':')
	;

protected WS_CHAR
	: (' ' | '\t' | '\n' | '\r')
	;

protected SUBST_OR_MATCH_OPER
	: ("tr" | "qq" | "qx" | "qw" | "qr" | 's' | 'y' | 'm' | 'q')
	;

OTHER: ~('\uFFFF');

protected KEYWORD1: ;
protected KEYWORD2: ;
protected KEYWORD_USE: ;
protected KEYWORD_SUB: ;
protected KEYWORD_FORMAT: ;
protected OPEN_QUOTE: ;

protected NEWLINE
	:
	(
	 '\r' '\n'	|	// DOS
     '\r'		|	// MacOS
     '\n'			// UNIX
    )
    { $setType(Token.SKIP); newline(); }
    ;

protected NOT_NEWLINE
	: ~('\r' | '\n' | '\uFFFF')
	;
