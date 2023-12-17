(******************************************************************************
 *                                                                            *
 *  File:        lua.pas                                                      *
 *  Authors:     TeCGraf           (C headers + actual Lua libraries)         *
 *               Lavergne Thomas   (original translation to Pascal)           *
 *               Bram Kuijvenhoven (update to Lua 5.1.1 for FreePascal)       *
 *               Yuri Lychakov     (update to LuaJIT 2.1 for FreePascal)      *
 *                                                                            *
 *  Description: Basic Lua library                                            *
 *               Lua auxiliary library                                        *
 *               Standard Lua libraries                                       *
 *  This is 3-in-1 replacement for FPC modules lua.pas,lauxlib.pas,lualib.pas *
 *                                                                            *
 ******************************************************************************)

(*
** $Id: lua.h,v 1.175 2003/03/18 12:31:39 roberto Exp $
** Lua - An Extensible Extension Language
** TeCGraf: Computer Graphics Technology Group, PUC-Rio, Brazil
** http://www.lua.org   mailto:info@lua.org
** See Copyright Notice at the end of this file
*)
(*
** Updated to Lua 5.1.1 by Bram Kuijvenhoven (bram at kuijvenhoven dot net),
**   Hexis BV (http://www.hexis.nl), the Netherlands
** Notes:
**    - Only tested with FPC (FreePascal Compiler)
**    - Using LuaBinaries styled DLL/SO names, which include version names
**    - LUA_YIELD was suffixed by '_' for avoiding name collision
*)
(*
** Translated to pascal by Lavergne Thomas
** Notes :
**    - Pointers type was prefixed with 'P'
**    - lua_upvalueindex constant was transformed to function
**    - Some compatibility function was isolated because with it you must have
**      lualib.
**    - LUA_VERSION was suffixed by '_' for avoiding name collision.
** Bug reports :
**    - thomas.lavergne@laposte.net
**   In french or in english
*)
(*
** Updated to LuaJIT 2.1 by Yuri Lychakov
** Notes:
**    - Only tested with FPC (FreePascal Compiler) (Windows, Linux, MacOS)
**    - All floating-point exceptions were forcibly disabled
**    - Dynamic library loading
*)

{$IFDEF FPC}{$MODE OBJFPC}{$H+}{$ENDIF}

unit LuaJIT;

interface

uses SysUtils, math;

type
    size_t = cardinal;
    Psize_t = ^size_t;

const
    LUA_VERSION_ = 'Lua 5.1';
    LUA_RELEASE = 'Lua 5.1.4';
    LUA_VERSION_NUM = 501;
    LUA_COPYRIGHT = 'Copyright (C) 1994-2008 Lua.org, PUC-Rio';
    LUA_AUTHORS = 'R. Ierusalimschy, L. H. de Figueiredo & W. Celes';

    (* option for multiple returns in `lua_pcall' and `lua_call' *)
    LUA_MULTRET = -1;

(*
** pseudo-indices
*)
    LUA_REGISTRYINDEX = -10000;
    LUA_ENVIRONINDEX = -10001;
    LUA_GLOBALSINDEX = -10002;

function lua_upvalueindex(I: integer): integer;

const
    (* thread status; 0 is OK *)
    LUA_OK = 0;
    LUA_YIELD_ = 1;
    LUA_ERRRUN = 2;
    LUA_ERRSYNTAX = 3;
    LUA_ERRMEM = 4;
    LUA_ERRERR = 5;

type
    Plua_State = Pointer;

    lua_CFunction = function(L: Plua_State): integer; cdecl;

(*
** functions that read/write blocks when loading/dumping Lua chunks
*)
type
    lua_Reader = function(L: Plua_State; ud: Pointer; sz: Psize_t): PChar; cdecl;
    lua_Writer = function(L: Plua_State; const p: Pointer; sz: size_t; ud: Pointer): integer; cdecl;

(*
** prototype for memory-allocation functions
*)
    lua_Alloc = function(ud, ptr: Pointer; osize, nsize: size_t): Pointer; cdecl;

(*
** basic types
*)
const
    LUA_TNONE = -1;

    LUA_TNIL = 0;
    LUA_TBOOLEAN = 1;
    LUA_TLIGHTUSERDATA = 2;
    LUA_TNUMBER = 3;
    LUA_TSTRING = 4;
    LUA_TTABLE = 5;
    LUA_TFUNCTION = 6;
    LUA_TUSERDATA = 7;
    LUA_TTHREAD = 8;

    (* minimum Lua stack available to a C function *)
    LUA_MINSTACK = 20;

type
    (* Type of Numbers in Lua *)
    lua_Number = double;
    lua_Integer = PtrInt;


(*
** Garbage-collection functions and options
*)
const
    LUA_GCSTOP = 0;
    LUA_GCRESTART = 1;
    LUA_GCCOLLECT = 2;
    LUA_GCCOUNT = 3;
    LUA_GCCOUNTB = 4;
    LUA_GCSTEP = 5;
    LUA_GCSETPAUSE = 6;
    LUA_GCSETSTEPMUL = 7;
    LUA_GCISRUNNING = 9;

(*
** ===============================================================
** some useful macros
** ===============================================================
*)

procedure lua_pop(L: Plua_State; n: integer);

procedure lua_newtable(L: Plua_state);

procedure lua_register(L: Plua_State; const n: PChar; f: lua_CFunction);
procedure lua_pushcfunction(L: Plua_State; f: lua_CFunction);

function lua_strlen(L: Plua_state; i: integer): size_t;

function lua_isfunction(L: Plua_State; n: integer): boolean;
function lua_istable(L: Plua_State; n: integer): boolean;
function lua_islightuserdata(L: Plua_State; n: integer): boolean;
function lua_isnil(L: Plua_State; n: integer): boolean;
function lua_isboolean(L: Plua_State; n: integer): boolean;
function lua_isthread(L: Plua_State; n: integer): boolean;
function lua_isnone(L: Plua_State; n: integer): boolean;
function lua_isnoneornil(L: Plua_State; n: integer): boolean;

procedure lua_pushliteral(L: Plua_State; s: PChar);

procedure lua_setglobal(L: Plua_State; const s: PChar);
procedure lua_getglobal(L: Plua_State; const s: PChar);

function lua_tostring(L: Plua_State; i: integer): PChar;

(*
** compatibility macros and functions
*)

procedure lua_getregistry(L: Plua_State);

function lua_getgccount(L: Plua_State): integer;

type
    lua_Chunkreader = lua_Reader;
    lua_Chunkwriter = lua_Writer;

(*
** {======================================================================
** Debug API
** =======================================================================
*)

const
    LUA_HOOKCALL = 0;
    LUA_HOOKRET = 1;
    LUA_HOOKLINE = 2;
    LUA_HOOKCOUNT = 3;
    LUA_HOOKTAILRET = 4;

const
    LUA_MASKCALL = 1 shl Ord(LUA_HOOKCALL);
    LUA_MASKRET = 1 shl Ord(LUA_HOOKRET);
    LUA_MASKLINE = 1 shl Ord(LUA_HOOKLINE);
    LUA_MASKCOUNT = 1 shl Ord(LUA_HOOKCOUNT);

const
    LUA_IDSIZE = 60;

type
    lua_Debug = record           (* activation record *)
        event: integer;
        Name: PChar;               (* (n) *)
        namewhat: PChar;           (* (n) `global', `local', `field', `method' *)
        what: PChar;               (* (S) `Lua', `C', `main', `tail'*)
        Source: PChar;             (* (S) *)
        currentline: integer;      (* (l) *)
        nups: integer;             (* (u) number of upvalues *)
        linedefined: integer;      (* (S) *)
        lastlinedefined: integer;  (* (S) *)
        short_src: array[0..LUA_IDSIZE - 1] of char; (* (S) *)
        (* private part *)
        i_ci: integer;              (* active function *)
    end;
    Plua_Debug = ^lua_Debug;

    lua_Hook = procedure(L: Plua_State; ar: Plua_Debug); cdecl;




    // lauxlib.pas
type
    luaL_reg = record
        Name: PChar;
        func: lua_CFunction;
    end;
    PluaL_reg = ^luaL_reg;



// functions added for Pascal
procedure lua_pushstring(L: Plua_State; const s: string);     // overload
procedure lua_pushstring(L: Plua_State; const s: PChar);

// compatibilty macros
procedure luaL_setfuncs(L: Plua_State; lr: array of luaL_Reg; nup: integer);  // overload
procedure luaL_setfuncs(L: Plua_State; lr: PluaL_Reg; nup: integer);


function lua_open: Plua_State; // compatibility; moved from unit lua to lauxlib because it needs luaL_newstate


(*
** ===============================================================
** some useful macros
** ===============================================================
*)

procedure luaL_argcheck(L: Plua_State; cond: boolean; numarg: integer; extramsg: PChar);
function luaL_checkstring(L: Plua_State; n: integer): PChar;
function luaL_optstring(L: Plua_State; n: integer; d: PChar): PChar;

function luaL_typename(L: Plua_State; i: integer): PChar;

function lua_dofile(L: Plua_State; const filename: PChar): integer;
function lua_dostring(L: Plua_State; const str: PChar): integer;

procedure lua_Lgetmetatable(L: Plua_State; tname: PChar);

// not translated:
// #define luaL_opt(L,f,n,d)    (lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))


(*
** =======================================================
** Generic Buffer manipulation
** =======================================================
*)

const
    // note: this is just arbitrary, as it related to the BUFSIZ defined in stdio.h ...
    LUAL_BUFFERSIZE = 4096;

type
    luaL_Buffer = record
        p: PChar;       (* current position in buffer *)
        lvl: integer;   (* number of strings in the stack (level) *)
        L: Plua_State;
        buffer: array [0..LUAL_BUFFERSIZE - 1] of char; // warning: see note above about LUAL_BUFFERSIZE
    end;
    PluaL_Buffer = ^luaL_Buffer;

    TluaL_setfuncs = procedure(L: Plua_State; lr: PluaL_Reg; nup: integer); cdecl;
    Tlua_newstate = function(f: lua_Alloc; ud: Pointer): Plua_State; cdecl;
    Tlua_close = procedure(L: Plua_State); cdecl;
    Tlua_newthread = function(L: Plua_State): Plua_State; cdecl;
    Tlua_atpanic = function(L: Plua_State; panicf: lua_CFunction): lua_CFunction; cdecl;
    Tlua_gettop = function(L: Plua_State): integer; cdecl;
    Tlua_settop = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_pushvalue = procedure(L: Plua_State; Idx: integer); cdecl;
    Tlua_remove = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_insert = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_replace = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_checkstack = function(L: Plua_State; sz: integer): longbool; cdecl;
    Tlua_xmove = procedure(from, to_: Plua_State; n: integer); cdecl;
    Tlua_isnumber = function(L: Plua_State; idx: integer): longbool; cdecl;
    Tlua_isstring = function(L: Plua_State; idx: integer): longbool; cdecl;
    Tlua_iscfunction = function(L: Plua_State; idx: integer): longbool; cdecl;
    Tlua_isuserdata = function(L: Plua_State; idx: integer): longbool; cdecl;
    Tlua_type = function(L: Plua_State; idx: integer): integer; cdecl;
    Tlua_typename = function(L: Plua_State; tp: integer): PChar; cdecl;
    Tlua_equal = function(L: Plua_State; idx1, idx2: integer): longbool; cdecl;
    Tlua_rawequal = function(L: Plua_State; idx1, idx2: integer): longbool; cdecl;
    Tlua_lessthan = function(L: Plua_State; idx1, idx2: integer): longbool; cdecl;
    Tlua_tonumber = function(L: Plua_State; idx: integer): lua_Number; cdecl;
    Tlua_tointeger = function(L: Plua_State; idx: integer): lua_Integer; cdecl;
    Tlua_toboolean = function(L: Plua_State; idx: integer): longbool; cdecl;
    Tlua_tolstring = function(L: Plua_State; idx: integer; len: Psize_t): PChar; cdecl;
    Tlua_objlen = function(L: Plua_State; idx: integer): size_t; cdecl;
    Tlua_tocfunction = function(L: Plua_State; idx: integer): lua_CFunction; cdecl;
    Tlua_touserdata = function(L: Plua_State; idx: integer): Pointer; cdecl;
    Tlua_tothread = function(L: Plua_State; idx: integer): Plua_State; cdecl;
    Tlua_topointer = function(L: Plua_State; idx: integer): Pointer; cdecl;
    Tlua_pushnil = procedure(L: Plua_State); cdecl;
    Tlua_pushnumber = procedure(L: Plua_State; n: lua_Number); cdecl;
    Tlua_pushinteger = procedure(L: Plua_State; n: lua_Integer); cdecl;
    Tlua_pushlstring = procedure(L: Plua_State; const s: PChar; l_: size_t); cdecl;
    Tlua_pushstring = procedure(L: Plua_State; const s: PChar); cdecl;
    Tlua_pushvfstring = function(L: Plua_State; const fmt: PChar; argp: Pointer): PChar; cdecl;
    Tlua_pushfstring = function(L: Plua_State; const fmt: PChar): PChar; cdecl; varargs;
    Tlua_pushcclosure = procedure(L: Plua_State; fn: lua_CFunction; n: integer); cdecl;
    Tlua_pushboolean = procedure(L: Plua_State; b: longbool); cdecl;
    Tlua_pushlightuserdata = procedure(L: Plua_State; p: Pointer); cdecl;
    Tlua_pushthread = procedure(L: Plua_State); cdecl;
    Tlua_gettable = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_getfield = procedure(L: Plua_state; idx: integer; k: PChar); cdecl;
    Tlua_rawget = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_rawgeti = procedure(L: Plua_State; idx, n: integer); cdecl;
    Tlua_createtable = procedure(L: Plua_State; narr, nrec: integer); cdecl;
    Tlua_newuserdata = function(L: Plua_State; sz: size_t): Pointer; cdecl;
    Tlua_getmetatable = function(L: Plua_State; objindex: integer): integer; cdecl;
    Tlua_getfenv = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_settable = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_setfield = procedure(L: Plua_State; idx: integer; k: PChar); cdecl;
    Tlua_rawset = procedure(L: Plua_State; idx: integer); cdecl;
    Tlua_rawseti = procedure(L: Plua_State; idx, n: integer); cdecl;
    Tlua_setmetatable = function(L: Plua_State; objindex: integer): integer; cdecl;
    Tlua_setfenv = function(L: Plua_State; idx: integer): integer; cdecl;
    Tlua_call = procedure(L: Plua_State; nargs, nresults: integer); cdecl;
    Tlua_pcall = function(L: Plua_State; nargs, nresults, errf: integer): integer; cdecl;
    Tlua_cpcall = function(L: Plua_State; func: lua_CFunction; ud: Pointer): integer; cdecl;
    Tlua_load = function(L: Plua_State; reader: lua_Reader; dt: Pointer; const chunkname: PChar): integer; cdecl;
    Tlua_dump = function(L: Plua_State; writer: lua_Writer; Data: Pointer): integer; cdecl;
    Tlua_yield = function(L: Plua_State; nresults: integer): integer; cdecl;
    Tlua_resume = function(L: Plua_State; narg: integer): integer; cdecl;
    Tlua_status = function(L: Plua_State): integer; cdecl;
    Tlua_gc = function(L: Plua_State; what, Data: integer): integer; cdecl;
    Tlua_error = function(L: Plua_State): integer; cdecl;
    Tlua_next = function(L: Plua_State; idx: integer): integer; cdecl;
    Tlua_concat = procedure(L: Plua_State; n: integer); cdecl;
    Tlua_getallocf = function(L: Plua_State; ud: PPointer): lua_Alloc; cdecl;
    Tlua_setallocf = procedure(L: Plua_State; f: lua_Alloc; ud: Pointer); cdecl;
    Tlua_getstack = function(L: Plua_State; level: integer; ar: Plua_Debug): integer; cdecl;
    Tlua_getinfo = function(L: Plua_State; const what: PChar; ar: Plua_Debug): integer; cdecl;
    Tlua_getlocal = function(L: Plua_State; const ar: Plua_Debug; n: integer): PChar; cdecl;
    Tlua_setlocal = function(L: Plua_State; const ar: Plua_Debug; n: integer): PChar; cdecl;
    Tlua_getupvalue = function(L: Plua_State; funcindex: integer; n: integer): PChar; cdecl;
    Tlua_setupvalue = function(L: Plua_State; funcindex: integer; n: integer): PChar; cdecl;
    Tlua_sethook = function(L: Plua_State; func: lua_Hook; mask: integer; Count: integer): integer; cdecl;
    Tlua_gethook = function(L: Plua_State): lua_Hook; cdecl;
    Tlua_gethookmask = function(L: Plua_State): integer; cdecl;
    Tlua_gethookcount = function(L: Plua_State): integer; cdecl;
    Tlua_upvalueid = function(L: Plua_State; funcindex, n: integer): Pointer; cdecl;  // From Lua 5.2
    Tlua_upvaluejoin = procedure(L: Plua_State; funcindex1, n1, funcindex2, n2: integer); cdecl; // From Lua 5.2
    Tlua_version = function(L: Plua_State): lua_Number; cdecl; // From Lua 5.2
    Tlua_copy = procedure(L: Plua_State; fromidx, toidx: integer); cdecl; // From Lua 5.2
    Tlua_tonumberx = function(L: Plua_State; idx: integer; isnum: PLongBool): lua_Number; cdecl; // From Lua 5.2
    Tlua_tointegerx = function(L: Plua_State; idx: integer; isnum: PLongBool): lua_Integer; cdecl; // From Lua 5.2
    Tlua_isyieldable = function(L: Plua_State): longbool; cdecl;   // From Lua 5.3
    TluaL_openlib = procedure(L: Plua_State; const libname: PChar; const lr: PluaL_reg; nup: integer); cdecl;
    TluaL_register = procedure(L: Plua_State; const libname: PChar; const lr: PluaL_reg); cdecl;
    TluaL_getmetafield = function(L: Plua_State; obj: integer; const e: PChar): integer; cdecl;
    TluaL_callmeta = function(L: Plua_State; obj: integer; const e: PChar): integer; cdecl;
    TluaL_typerror = function(L: Plua_State; narg: integer; const tname: PChar): integer; cdecl;
    TluaL_argerror = function(L: Plua_State; numarg: integer; const extramsg: PChar): integer; cdecl;
    TluaL_checklstring = function(L: Plua_State; numArg: integer; l_: Psize_t): PChar; cdecl;
    TluaL_optlstring = function(L: Plua_State; numArg: integer; const def: PChar; l_: Psize_t): PChar; cdecl;
    TluaL_checknumber = function(L: Plua_State; numArg: integer): lua_Number; cdecl;
    TluaL_optnumber = function(L: Plua_State; nArg: integer; def: lua_Number): lua_Number; cdecl;
    TluaL_checkinteger = function(L: Plua_State; numArg: integer): lua_Integer; cdecl;
    TluaL_optinteger = function(L: Plua_State; nArg: integer; def: lua_Integer): lua_Integer; cdecl;
    TluaL_checkstack = procedure(L: Plua_State; sz: integer; const msg: PChar); cdecl;
    TluaL_checktype = procedure(L: Plua_State; narg, t: integer); cdecl;
    TluaL_checkany = procedure(L: Plua_State; narg: integer); cdecl;
    TluaL_newmetatable = function(L: Plua_State; const tname: PChar): integer; cdecl;
    TluaL_checkudata = function(L: Plua_State; ud: integer; const tname: PChar): Pointer; cdecl;
    TluaL_where = procedure(L: Plua_State; lvl: integer); cdecl;
    TluaL_error = function(L: Plua_State; const fmt: pansichar): integer; cdecl; varargs;
    TluaL_checkoption = function(L: Plua_State; narg: integer; def: PChar; lst: PPChar): integer; cdecl;
    TluaL_fileresult = function(L: Plua_State; stat: integer; const fname: pansichar): integer; cdecl;
    TluaL_execresult = function(L: Plua_State; stat: integer): integer; cdecl;
    TluaL_loadfilex = function(L: Plua_State; const filename, mode: pansichar): integer; cdecl;
    TluaL_loadbufferx = function(L: Plua_State; const buff: pansichar; sz: size_t; const Name, mode: pansichar): integer; cdecl;
    TluaL_traceback = procedure(L, L1: Plua_State; msg: pansichar; level: integer); cdecl;
    TluaL_testudata = function(L: Plua_State; ud: integer; const tname: pansichar): Pointer; cdecl;
    TluaL_setmetatable = procedure(L: Plua_State; const tname: pansichar); cdecl;
    TluaL_ref = function(L: Plua_State; t: integer): integer; cdecl;
    TluaL_unref = procedure(L: Plua_State; t, ref: integer); cdecl;
    TluaL_loadfile = function(L: Plua_State; const filename: PChar): integer; cdecl;
    TluaL_loadbuffer = function(L: Plua_State; const buff: PChar; size: size_t; const Name: PChar): integer; cdecl;
    TluaL_loadstring = function(L: Plua_State; const s: PChar): integer; cdecl;
    TluaL_newstate = function: Plua_State; cdecl;
    TluaL_gsub = function(L: Plua_State; const s, p, r: PChar): PChar; cdecl;
    TluaL_findtable = function(L: Plua_State; idx: integer; const fname: PChar; szhint: integer): PChar; cdecl;
    TluaL_buffinit = procedure(L: Plua_State; B: PluaL_Buffer); cdecl;
    TluaL_prepbuffer = function(B: PluaL_Buffer): PChar; cdecl;
    TluaL_addlstring = procedure(B: PluaL_Buffer; const s: PChar; l: size_t); cdecl;
    TluaL_addstring = procedure(B: PluaL_Buffer; const s: PChar); cdecl;
    TluaL_addvalue = procedure(B: PluaL_Buffer); cdecl;
    TluaL_pushresult = procedure(B: PluaL_Buffer); cdecl;
    Tluaopen_base = function(L: Plua_State): longbool; cdecl;
    Tluaopen_table = function(L: Plua_State): longbool; cdecl;
    Tluaopen_io = function(L: Plua_State): longbool; cdecl;
    Tluaopen_string = function(L: Plua_State): longbool; cdecl;
    Tluaopen_math = function(L: Plua_State): longbool; cdecl;
    Tluaopen_debug = function(L: Plua_State): longbool; cdecl;
    Tluaopen_package = function(L: Plua_State): longbool; cdecl;
    Tluaopen_bit = function(L: Plua_State): longbool; cdecl;
    Tluaopen_jit = function(L: Plua_State): longbool; cdecl;
    Tluaopen_ffi = function(L: Plua_State): longbool; cdecl;
    Tluaopen_string_buffer = function(L: Plua_State): longbool; cdecl;
    TluaL_openlibs = procedure(L: Plua_State); cdecl;

procedure luaL_addchar(B: PluaL_Buffer; c: char); // warning: see note above about LUAL_BUFFERSIZE

(* compatibility only (alias for luaL_addchar) *)
procedure luaL_addsize(B: PluaL_Buffer; n: integer);


(* compatibility with ref system *)

(* pre-defined references *)
const
    LUA_NOREF = -2;
    LUA_REFNIL = -1;



// lualib.pas

const
    LUA_COLIBNAME = 'coroutine';
    LUA_TABLIBNAME = 'table';
    LUA_IOLIBNAME = 'io';
    LUA_OSLIBNAME = 'os';
    LUA_STRLINAME = 'string';
    LUA_MATHLIBNAME = 'math';
    LUA_DBLIBNAME = 'debug';
    LUA_LOADLIBNAME = 'package';
    LUA_BITLIBNAME = 'bit';
    LUA_JITLIBNAME = 'jit';
    LUA_FFILIBNAME = 'ffi';


function LuaInit(lib: string): boolean;
procedure LuaDeInit;


var
    luaL_setfuncs_: TluaL_setfuncs;
    lua_newstate: Tlua_newstate;
    lua_close: Tlua_close;
    lua_newthread: Tlua_newthread;
    lua_atpanic: Tlua_atpanic;
    lua_gettop: Tlua_gettop;
    lua_settop: Tlua_settop;
    lua_pushvalue: Tlua_pushvalue;
    lua_remove: Tlua_remove;
    lua_insert: Tlua_insert;
    lua_replace: Tlua_replace;
    lua_checkstack: Tlua_checkstack;
    lua_xmove: Tlua_xmove;
    lua_isnumber: Tlua_isnumber;
    lua_isstring: Tlua_isstring;
    lua_iscfunction: Tlua_iscfunction;
    lua_isuserdata: Tlua_isuserdata;
    lua_type: Tlua_type;
    lua_typename: Tlua_typename;
    lua_equal: Tlua_equal;
    lua_rawequal: Tlua_rawequal;
    lua_lessthan: Tlua_lessthan;
    lua_tonumber: Tlua_tonumber;
    lua_tointeger: Tlua_tointeger;
    lua_toboolean: Tlua_toboolean;
    lua_tolstring: Tlua_tolstring;
    lua_objlen: Tlua_objlen;
    lua_tocfunction: Tlua_tocfunction;
    lua_touserdata: Tlua_touserdata;
    lua_tothread: Tlua_tothread;
    lua_topointer: Tlua_topointer;
    lua_pushnil: Tlua_pushnil;
    lua_pushnumber: Tlua_pushnumber;
    lua_pushinteger: Tlua_pushinteger;
    lua_pushlstring: Tlua_pushlstring;
    lua_pushstring_: Tlua_pushstring;
    lua_pushvfstring: Tlua_pushvfstring;
    lua_pushfstring: Tlua_pushfstring;
    lua_pushcclosure: Tlua_pushcclosure;
    lua_pushboolean: Tlua_pushboolean;
    lua_pushlightuserdata: Tlua_pushlightuserdata;
    lua_pushthread: Tlua_pushthread;
    lua_gettable: Tlua_gettable;
    lua_getfield: Tlua_getfield;
    lua_rawget: Tlua_rawget;
    lua_rawgeti: Tlua_rawgeti;
    lua_createtable: Tlua_createtable;
    lua_newuserdata: Tlua_newuserdata;
    lua_getmetatable: Tlua_getmetatable;
    lua_getfenv: Tlua_getfenv;
    lua_settable: Tlua_settable;
    lua_setfield: Tlua_setfield;
    lua_rawset: Tlua_rawset;
    lua_rawseti: Tlua_rawseti;
    lua_setmetatable: Tlua_setmetatable;
    lua_setfenv: Tlua_setfenv;
    lua_call: Tlua_call;
    lua_pcall: Tlua_pcall;
    lua_cpcall: Tlua_cpcall;
    lua_load: Tlua_load;
    lua_dump: Tlua_dump;
    lua_yield: Tlua_yield;
    lua_resume: Tlua_resume;
    lua_status: Tlua_status;
    lua_gc: Tlua_gc;
    lua_error: Tlua_error;
    lua_next: Tlua_next;
    lua_concat: Tlua_concat;
    lua_getallocf: Tlua_getallocf;
    lua_setallocf: Tlua_setallocf;
    lua_getstack: Tlua_getstack;
    lua_getinfo: Tlua_getinfo;
    lua_getlocal: Tlua_getlocal;
    lua_setlocal: Tlua_setlocal;
    lua_getupvalue: Tlua_getupvalue;
    lua_setupvalue: Tlua_setupvalue;
    lua_sethook: Tlua_sethook;
    lua_gethook: Tlua_gethook;
    lua_gethookmask: Tlua_gethookmask;
    lua_gethookcount: Tlua_gethookcount;
    lua_upvalueid: Tlua_upvalueid;
    lua_upvaluejoin: Tlua_upvaluejoin;
    lua_version: Tlua_version;
    lua_copy: Tlua_copy;
    lua_tonumberx: Tlua_tonumberx;
    lua_tointegerx: Tlua_tointegerx;
    lua_isyieldable: Tlua_isyieldable;
    luaL_openlib: TluaL_openlib;
    luaL_register: TluaL_register;
    luaL_getmetafield: TluaL_getmetafield;
    luaL_callmeta: TluaL_callmeta;
    luaL_typerror: TluaL_typerror;
    luaL_argerror: TluaL_argerror;
    luaL_checklstring: TluaL_checklstring;
    luaL_optlstring: TluaL_optlstring;
    luaL_checknumber: TluaL_checknumber;
    luaL_optnumber: TluaL_optnumber;
    luaL_checkinteger: TluaL_checkinteger;
    luaL_optinteger: TluaL_optinteger;
    luaL_checkstack: TluaL_checkstack;
    luaL_checktype: TluaL_checktype;
    luaL_checkany: TluaL_checkany;
    luaL_newmetatable: TluaL_newmetatable;
    luaL_checkudata: TluaL_checkudata;
    luaL_where: TluaL_where;
    luaL_error: TluaL_error;
    luaL_checkoption: TluaL_checkoption;
    luaL_fileresult: TluaL_fileresult;
    luaL_execresult: TluaL_execresult;
    luaL_loadfilex: TluaL_loadfilex;
    luaL_loadbufferx: TluaL_loadbufferx;
    luaL_traceback: TluaL_traceback;
    luaL_testudata: TluaL_testudata;
    luaL_setmetatable: TluaL_setmetatable;
    luaL_ref: TluaL_ref;
    luaL_unref: TluaL_unref;
    luaL_loadfile: TluaL_loadfile;
    luaL_loadbuffer: TluaL_loadbuffer;
    luaL_loadstring: TluaL_loadstring;
    luaL_newstate: TluaL_newstate;
    luaL_gsub: TluaL_gsub;
    luaL_findtable: TluaL_findtable;
    luaL_buffinit: TluaL_buffinit;
    luaL_prepbuffer: TluaL_prepbuffer;
    luaL_addlstring: TluaL_addlstring;
    luaL_addstring: TluaL_addstring;
    luaL_addvalue: TluaL_addvalue;
    luaL_pushresult: TluaL_pushresult;
    luaopen_base: Tluaopen_base;
    luaopen_table: Tluaopen_table;
    luaopen_io: Tluaopen_io;
    luaopen_string: Tluaopen_string;
    luaopen_math: Tluaopen_math;
    luaopen_debug: Tluaopen_debug;
    luaopen_package: Tluaopen_package;
    luaopen_bit: Tluaopen_bit;
    luaopen_jit: Tluaopen_jit;
    luaopen_ffi: Tluaopen_ffi;
    luaopen_string_buffer: Tluaopen_string_buffer;
    luaL_openlibs: TluaL_openlibs;

    LuaLibHandle: TLibHandle;

implementation

function lua_upvalueindex(I: integer): integer;
begin
    Result := LUA_GLOBALSINDEX - i;
end;

procedure lua_pop(L: Plua_State; n: integer);
begin
    lua_settop(L, -n - 1);
end;

procedure lua_newtable(L: Plua_State);
begin
    lua_createtable(L, 0, 0);
end;

procedure lua_register(L: Plua_State; const n: PChar; f: lua_CFunction);
begin
    lua_pushcfunction(L, f);
    lua_setglobal(L, n);
end;

procedure lua_pushcfunction(L: Plua_State; f: lua_CFunction);
begin
    lua_pushcclosure(L, f, 0);
end;

function lua_strlen(L: Plua_State; i: integer): size_t;
begin
    Result := lua_objlen(L, i);
end;

function lua_isfunction(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TFUNCTION;
end;

function lua_istable(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TTABLE;
end;

function lua_islightuserdata(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TLIGHTUSERDATA;
end;

function lua_isnil(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TNIL;
end;

function lua_isboolean(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TBOOLEAN;
end;

function lua_isthread(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TTHREAD;
end;

function lua_isnone(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) = LUA_TNONE;
end;

function lua_isnoneornil(L: Plua_State; n: integer): boolean;
begin
    Result := lua_type(L, n) <= 0;
end;

procedure lua_pushliteral(L: Plua_State; s: PChar);
begin
    lua_pushlstring(L, s, Length(s));
end;

procedure lua_setglobal(L: Plua_State; const s: PChar);
begin
    lua_setfield(L, LUA_GLOBALSINDEX, s);
end;

procedure lua_getglobal(L: Plua_State; const s: PChar);
begin
    lua_getfield(L, LUA_GLOBALSINDEX, s);
end;

function lua_tostring(L: Plua_State; i: integer): PChar;
begin
    Result := lua_tolstring(L, i, nil);
end;


procedure lua_getregistry(L: Plua_State);
begin
    lua_pushvalue(L, LUA_REGISTRYINDEX);
end;

function lua_getgccount(L: Plua_State): integer;
begin
    Result := lua_gc(L, LUA_GCCOUNT, 0);
end;

(*
** {======================================================================
** Debug API
** =======================================================================
*)


// lauxlib.pas
procedure lua_pushstring(L: Plua_State; const s: string);
begin
    lua_pushlstring(L, PChar(s), Length(s));
end;

procedure lua_pushstring(L: Plua_State; const s: PChar);
begin
    lua_pushstring_(L, s);
end;

function lua_open: Plua_State;
begin
    Result := luaL_newstate;
end;

function luaL_typename(L: Plua_State; i: integer): PChar;
begin
    Result := lua_typename(L, lua_type(L, i));
end;

function lua_dofile(L: Plua_State; const filename: PChar): integer;
begin
    Result := luaL_loadfile(L, filename);
    if Result = 0 then
        Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

function lua_dostring(L: Plua_State; const str: PChar): integer;
begin
    Result := luaL_loadstring(L, str);
    if Result = 0 then
        Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

procedure lua_Lgetmetatable(L: Plua_State; tname: PChar);
begin
    lua_getfield(L, LUA_REGISTRYINDEX, tname);
end;

procedure luaL_setfuncs(L: Plua_State; lr: array of luaL_Reg; nup: integer);
begin
    luaL_setfuncs_(L, @lr, nup);
end;

procedure luaL_setfuncs(L: Plua_State; lr: PluaL_Reg; nup: integer);
begin
    luaL_setfuncs_(L, lr, nup);
end;

procedure luaL_argcheck(L: Plua_State; cond: boolean; numarg: integer; extramsg: PChar);
begin
    if not cond then
        luaL_argerror(L, numarg, extramsg);
end;

function luaL_checkstring(L: Plua_State; n: integer): PChar;
begin
    Result := luaL_checklstring(L, n, nil);
end;

function luaL_optstring(L: Plua_State; n: integer; d: PChar): PChar;
begin
    Result := luaL_optlstring(L, n, d, nil);
end;

procedure luaL_addchar(B: PluaL_Buffer; c: char);
begin
    if cardinal(@(B^.p)) < (cardinal(@(B^.buffer[0])) + LUAL_BUFFERSIZE) then
        luaL_prepbuffer(B);
    B^.p[1] := c;
    B^.p := B^.p + 1;
end;

procedure luaL_addsize(B: PluaL_Buffer; n: integer);
begin
    B^.p := B^.p + n;
end;

function LuaInit(lib: string): boolean;
begin
    Result := False;
    if lib = '' then exit;
    LuaLibHandle := SafeLoadLibrary(lib);
    if LuaLibHandle = 0 then exit;

    Pointer(luaL_setfuncs_) := GetProcAddress(LuaLibHandle, 'luaL_setfuncs');
    Pointer(lua_newstate) := GetProcAddress(LuaLibHandle, 'lua_newstate');
    Pointer(lua_close) := GetProcAddress(LuaLibHandle, 'lua_close');
    Pointer(lua_newthread) := GetProcAddress(LuaLibHandle, 'lua_newthread');
    Pointer(lua_atpanic) := GetProcAddress(LuaLibHandle, 'lua_atpanic');
    Pointer(lua_gettop) := GetProcAddress(LuaLibHandle, 'lua_gettop');
    Pointer(lua_settop) := GetProcAddress(LuaLibHandle, 'lua_settop');
    Pointer(lua_pushvalue) := GetProcAddress(LuaLibHandle, 'lua_pushvalue');
    Pointer(lua_remove) := GetProcAddress(LuaLibHandle, 'lua_remove');
    Pointer(lua_insert) := GetProcAddress(LuaLibHandle, 'lua_insert');
    Pointer(lua_replace) := GetProcAddress(LuaLibHandle, 'lua_replace');
    Pointer(lua_checkstack) := GetProcAddress(LuaLibHandle, 'lua_checkstack');
    Pointer(lua_xmove) := GetProcAddress(LuaLibHandle, 'lua_xmove');
    Pointer(lua_isnumber) := GetProcAddress(LuaLibHandle, 'lua_isnumber');
    Pointer(lua_isstring) := GetProcAddress(LuaLibHandle, 'lua_isstring');
    Pointer(lua_iscfunction) := GetProcAddress(LuaLibHandle, 'lua_iscfunction');
    Pointer(lua_isuserdata) := GetProcAddress(LuaLibHandle, 'lua_isuserdata');
    Pointer(lua_type) := GetProcAddress(LuaLibHandle, 'lua_type');
    Pointer(lua_typename) := GetProcAddress(LuaLibHandle, 'lua_typename');
    Pointer(lua_equal) := GetProcAddress(LuaLibHandle, 'lua_equal');
    Pointer(lua_rawequal) := GetProcAddress(LuaLibHandle, 'lua_rawequal');
    Pointer(lua_lessthan) := GetProcAddress(LuaLibHandle, 'lua_lessthan');
    Pointer(lua_tonumber) := GetProcAddress(LuaLibHandle, 'lua_tonumber');
    Pointer(lua_tointeger) := GetProcAddress(LuaLibHandle, 'lua_tointeger');
    Pointer(lua_toboolean) := GetProcAddress(LuaLibHandle, 'lua_toboolean');
    Pointer(lua_tolstring) := GetProcAddress(LuaLibHandle, 'lua_tolstring');
    Pointer(lua_objlen) := GetProcAddress(LuaLibHandle, 'lua_objlen');
    Pointer(lua_tocfunction) := GetProcAddress(LuaLibHandle, 'lua_tocfunction');
    Pointer(lua_touserdata) := GetProcAddress(LuaLibHandle, 'lua_touserdata');
    Pointer(lua_tothread) := GetProcAddress(LuaLibHandle, 'lua_tothread');
    Pointer(lua_topointer) := GetProcAddress(LuaLibHandle, 'lua_topointer');
    Pointer(lua_pushnil) := GetProcAddress(LuaLibHandle, 'lua_pushnil');
    Pointer(lua_pushnumber) := GetProcAddress(LuaLibHandle, 'lua_pushnumber');
    Pointer(lua_pushinteger) := GetProcAddress(LuaLibHandle, 'lua_pushinteger');
    Pointer(lua_pushlstring) := GetProcAddress(LuaLibHandle, 'lua_pushlstring');
    Pointer(lua_pushstring_) := GetProcAddress(LuaLibHandle, 'lua_pushstring');
    Pointer(lua_pushvfstring) := GetProcAddress(LuaLibHandle, 'lua_pushvfstring');
    Pointer(lua_pushfstring) := GetProcAddress(LuaLibHandle, 'lua_pushfstring');
    Pointer(lua_pushcclosure) := GetProcAddress(LuaLibHandle, 'lua_pushcclosure');
    Pointer(lua_pushboolean) := GetProcAddress(LuaLibHandle, 'lua_pushboolean');
    Pointer(lua_pushlightuserdata) := GetProcAddress(LuaLibHandle, 'lua_pushlightuserdata');
    Pointer(lua_pushthread) := GetProcAddress(LuaLibHandle, 'lua_pushthread');
    Pointer(lua_gettable) := GetProcAddress(LuaLibHandle, 'lua_gettable');
    Pointer(lua_getfield) := GetProcAddress(LuaLibHandle, 'lua_getfield');
    Pointer(lua_rawget) := GetProcAddress(LuaLibHandle, 'lua_rawget');
    Pointer(lua_rawgeti) := GetProcAddress(LuaLibHandle, 'lua_rawgeti');
    Pointer(lua_createtable) := GetProcAddress(LuaLibHandle, 'lua_createtable');
    Pointer(lua_newuserdata) := GetProcAddress(LuaLibHandle, 'lua_newuserdata');
    Pointer(lua_getmetatable) := GetProcAddress(LuaLibHandle, 'lua_getmetatable');
    Pointer(lua_getfenv) := GetProcAddress(LuaLibHandle, 'lua_getfenv');
    Pointer(lua_settable) := GetProcAddress(LuaLibHandle, 'lua_settable');
    Pointer(lua_setfield) := GetProcAddress(LuaLibHandle, 'lua_setfield');
    Pointer(lua_rawset) := GetProcAddress(LuaLibHandle, 'lua_rawset');
    Pointer(lua_rawseti) := GetProcAddress(LuaLibHandle, 'lua_rawseti');
    Pointer(lua_setmetatable) := GetProcAddress(LuaLibHandle, 'lua_setmetatable');
    Pointer(lua_setfenv) := GetProcAddress(LuaLibHandle, 'lua_setfenv');
    Pointer(lua_call) := GetProcAddress(LuaLibHandle, 'lua_call');
    Pointer(lua_pcall) := GetProcAddress(LuaLibHandle, 'lua_pcall');
    Pointer(lua_cpcall) := GetProcAddress(LuaLibHandle, 'lua_cpcall');
    Pointer(lua_load) := GetProcAddress(LuaLibHandle, 'lua_load');
    Pointer(lua_dump) := GetProcAddress(LuaLibHandle, 'lua_dump');
    Pointer(lua_yield) := GetProcAddress(LuaLibHandle, 'lua_yield');
    Pointer(lua_resume) := GetProcAddress(LuaLibHandle, 'lua_resume');
    Pointer(lua_status) := GetProcAddress(LuaLibHandle, 'lua_status');
    Pointer(lua_gc) := GetProcAddress(LuaLibHandle, 'lua_gc');
    Pointer(lua_error) := GetProcAddress(LuaLibHandle, 'lua_error');
    Pointer(lua_next) := GetProcAddress(LuaLibHandle, 'lua_next');
    Pointer(lua_concat) := GetProcAddress(LuaLibHandle, 'lua_concat');
    Pointer(lua_getallocf) := GetProcAddress(LuaLibHandle, 'lua_getallocf');
    Pointer(lua_setallocf) := GetProcAddress(LuaLibHandle, 'lua_setallocf');
    Pointer(lua_getstack) := GetProcAddress(LuaLibHandle, 'lua_getstack');
    Pointer(lua_getinfo) := GetProcAddress(LuaLibHandle, 'lua_getinfo');
    Pointer(lua_getlocal) := GetProcAddress(LuaLibHandle, 'lua_getlocal');
    Pointer(lua_setlocal) := GetProcAddress(LuaLibHandle, 'lua_setlocal');
    Pointer(lua_getupvalue) := GetProcAddress(LuaLibHandle, 'lua_getupvalue');
    Pointer(lua_setupvalue) := GetProcAddress(LuaLibHandle, 'lua_setupvalue');
    Pointer(lua_sethook) := GetProcAddress(LuaLibHandle, 'lua_sethook');
    Pointer(lua_gethook) := GetProcAddress(LuaLibHandle, 'lua_gethook');
    Pointer(lua_gethookmask) := GetProcAddress(LuaLibHandle, 'lua_gethookmask');
    Pointer(lua_gethookcount) := GetProcAddress(LuaLibHandle, 'lua_gethookcount');
    Pointer(lua_upvalueid) := GetProcAddress(LuaLibHandle, 'lua_upvalueid');
    Pointer(lua_upvaluejoin) := GetProcAddress(LuaLibHandle, 'lua_upvaluejoin');
    Pointer(lua_version) := GetProcAddress(LuaLibHandle, 'lua_version');
    Pointer(lua_copy) := GetProcAddress(LuaLibHandle, 'lua_copy');
    Pointer(lua_tonumberx) := GetProcAddress(LuaLibHandle, 'lua_tonumberx');
    Pointer(lua_tointegerx) := GetProcAddress(LuaLibHandle, 'lua_tointegerx');
    Pointer(lua_isyieldable) := GetProcAddress(LuaLibHandle, 'lua_isyieldable');
    Pointer(luaL_openlib) := GetProcAddress(LuaLibHandle, 'luaL_openlib');
    Pointer(luaL_register) := GetProcAddress(LuaLibHandle, 'luaL_register');
    Pointer(luaL_getmetafield) := GetProcAddress(LuaLibHandle, 'luaL_getmetafield');
    Pointer(luaL_callmeta) := GetProcAddress(LuaLibHandle, 'luaL_callmeta');
    Pointer(luaL_typerror) := GetProcAddress(LuaLibHandle, 'luaL_typerror');
    Pointer(luaL_argerror) := GetProcAddress(LuaLibHandle, 'luaL_argerror');
    Pointer(luaL_checklstring) := GetProcAddress(LuaLibHandle, 'luaL_checklstring');
    Pointer(luaL_optlstring) := GetProcAddress(LuaLibHandle, 'luaL_optlstring');
    Pointer(luaL_checknumber) := GetProcAddress(LuaLibHandle, 'luaL_checknumber');
    Pointer(luaL_optnumber) := GetProcAddress(LuaLibHandle, 'luaL_optnumber');
    Pointer(luaL_checkinteger) := GetProcAddress(LuaLibHandle, 'luaL_checkinteger');
    Pointer(luaL_optinteger) := GetProcAddress(LuaLibHandle, 'luaL_optinteger');
    Pointer(luaL_checkstack) := GetProcAddress(LuaLibHandle, 'luaL_checkstack');
    Pointer(luaL_checktype) := GetProcAddress(LuaLibHandle, 'luaL_checktype');
    Pointer(luaL_checkany) := GetProcAddress(LuaLibHandle, 'luaL_checkany');
    Pointer(luaL_newmetatable) := GetProcAddress(LuaLibHandle, 'luaL_newmetatable');
    Pointer(luaL_checkudata) := GetProcAddress(LuaLibHandle, 'luaL_checkudata');
    Pointer(luaL_where) := GetProcAddress(LuaLibHandle, 'luaL_where');
    Pointer(luaL_error) := GetProcAddress(LuaLibHandle, 'luaL_error');
    Pointer(luaL_checkoption) := GetProcAddress(LuaLibHandle, 'luaL_checkoption');
    Pointer(luaL_fileresult) := GetProcAddress(LuaLibHandle, 'luaL_fileresult');
    Pointer(luaL_execresult) := GetProcAddress(LuaLibHandle, 'luaL_execresult');
    Pointer(luaL_loadfilex) := GetProcAddress(LuaLibHandle, 'luaL_loadfilex');
    Pointer(luaL_loadbufferx) := GetProcAddress(LuaLibHandle, 'luaL_loadbufferx');
    Pointer(luaL_traceback) := GetProcAddress(LuaLibHandle, 'luaL_traceback');
    Pointer(luaL_testudata) := GetProcAddress(LuaLibHandle, 'luaL_testudata');
    Pointer(luaL_setmetatable) := GetProcAddress(LuaLibHandle, 'luaL_setmetatable');
    Pointer(luaL_ref) := GetProcAddress(LuaLibHandle, 'luaL_ref');
    Pointer(luaL_unref) := GetProcAddress(LuaLibHandle, 'luaL_unref');
    Pointer(luaL_loadfile) := GetProcAddress(LuaLibHandle, 'luaL_loadfile');
    Pointer(luaL_loadbuffer) := GetProcAddress(LuaLibHandle, 'luaL_loadbuffer');
    Pointer(luaL_loadstring) := GetProcAddress(LuaLibHandle, 'luaL_loadstring');
    Pointer(luaL_newstate) := GetProcAddress(LuaLibHandle, 'luaL_newstate');
    Pointer(luaL_gsub) := GetProcAddress(LuaLibHandle, 'luaL_gsub');
    Pointer(luaL_findtable) := GetProcAddress(LuaLibHandle, 'luaL_findtable');
    Pointer(luaL_buffinit) := GetProcAddress(LuaLibHandle, 'luaL_buffinit');
    Pointer(luaL_prepbuffer) := GetProcAddress(LuaLibHandle, 'luaL_prepbuffer');
    Pointer(luaL_addlstring) := GetProcAddress(LuaLibHandle, 'luaL_addlstring');
    Pointer(luaL_addstring) := GetProcAddress(LuaLibHandle, 'luaL_addstring');
    Pointer(luaL_addvalue) := GetProcAddress(LuaLibHandle, 'luaL_addvalue');
    Pointer(luaL_pushresult) := GetProcAddress(LuaLibHandle, 'luaL_pushresult');
    Pointer(luaopen_base) := GetProcAddress(LuaLibHandle, 'luaopen_base');
    Pointer(luaopen_table) := GetProcAddress(LuaLibHandle, 'luaopen_table');
    Pointer(luaopen_io) := GetProcAddress(LuaLibHandle, 'luaopen_io');
    Pointer(luaopen_string) := GetProcAddress(LuaLibHandle, 'luaopen_string');
    Pointer(luaopen_math) := GetProcAddress(LuaLibHandle, 'luaopen_math');
    Pointer(luaopen_debug) := GetProcAddress(LuaLibHandle, 'luaopen_debug');
    Pointer(luaopen_package) := GetProcAddress(LuaLibHandle, 'luaopen_package');
    Pointer(luaopen_bit) := GetProcAddress(LuaLibHandle, 'luaopen_bit');
    Pointer(luaopen_jit) := GetProcAddress(LuaLibHandle, 'luaopen_jit');
    Pointer(luaopen_ffi) := GetProcAddress(LuaLibHandle, 'luaopen_ffi');
    Pointer(luaopen_string_buffer) := GetProcAddress(LuaLibHandle, 'luaopen_string_buffer');
    Pointer(luaL_openlibs) := GetProcAddress(LuaLibHandle, 'luaL_openlibs');

    if not Assigned(luaL_setfuncs_) then Exit;
    if not Assigned(lua_newstate) then Exit;
    if not Assigned(lua_close) then Exit;
    if not Assigned(lua_newthread) then Exit;
    if not Assigned(lua_atpanic) then Exit;
    if not Assigned(lua_gettop) then Exit;
    if not Assigned(lua_settop) then Exit;
    if not Assigned(lua_pushvalue) then Exit;
    if not Assigned(lua_remove) then Exit;
    if not Assigned(lua_insert) then Exit;
    if not Assigned(lua_replace) then Exit;
    if not Assigned(lua_checkstack) then Exit;
    if not Assigned(lua_xmove) then Exit;
    if not Assigned(lua_isnumber) then Exit;
    if not Assigned(lua_isstring) then Exit;
    if not Assigned(lua_iscfunction) then Exit;
    if not Assigned(lua_isuserdata) then Exit;
    if not Assigned(lua_type) then Exit;
    if not Assigned(lua_typename) then Exit;
    if not Assigned(lua_equal) then Exit;
    if not Assigned(lua_rawequal) then Exit;
    if not Assigned(lua_lessthan) then Exit;
    if not Assigned(lua_tonumber) then Exit;
    if not Assigned(lua_tointeger) then Exit;
    if not Assigned(lua_toboolean) then Exit;
    if not Assigned(lua_tolstring) then Exit;
    if not Assigned(lua_objlen) then Exit;
    if not Assigned(lua_tocfunction) then Exit;
    if not Assigned(lua_touserdata) then Exit;
    if not Assigned(lua_tothread) then Exit;
    if not Assigned(lua_topointer) then Exit;
    if not Assigned(lua_pushnil) then Exit;
    if not Assigned(lua_pushnumber) then Exit;
    if not Assigned(lua_pushinteger) then Exit;
    if not Assigned(lua_pushlstring) then Exit;
    if not Assigned(lua_pushstring_) then Exit;
    if not Assigned(lua_pushvfstring) then Exit;
    if not Assigned(lua_pushfstring) then Exit;
    if not Assigned(lua_pushcclosure) then Exit;
    if not Assigned(lua_pushboolean) then Exit;
    if not Assigned(lua_pushlightuserdata) then Exit;
    if not Assigned(lua_pushthread) then Exit;
    if not Assigned(lua_gettable) then Exit;
    if not Assigned(lua_getfield) then Exit;
    if not Assigned(lua_rawget) then Exit;
    if not Assigned(lua_rawgeti) then Exit;
    if not Assigned(lua_createtable) then Exit;
    if not Assigned(lua_newuserdata) then Exit;
    if not Assigned(lua_getmetatable) then Exit;
    if not Assigned(lua_getfenv) then Exit;
    if not Assigned(lua_settable) then Exit;
    if not Assigned(lua_setfield) then Exit;
    if not Assigned(lua_rawset) then Exit;
    if not Assigned(lua_rawseti) then Exit;
    if not Assigned(lua_setmetatable) then Exit;
    if not Assigned(lua_setfenv) then Exit;
    if not Assigned(lua_call) then Exit;
    if not Assigned(lua_pcall) then Exit;
    if not Assigned(lua_cpcall) then Exit;
    if not Assigned(lua_load) then Exit;
    if not Assigned(lua_dump) then Exit;
    if not Assigned(lua_yield) then Exit;
    if not Assigned(lua_resume) then Exit;
    if not Assigned(lua_status) then Exit;
    if not Assigned(lua_gc) then Exit;
    if not Assigned(lua_error) then Exit;
    if not Assigned(lua_next) then Exit;
    if not Assigned(lua_concat) then Exit;
    if not Assigned(lua_getallocf) then Exit;
    if not Assigned(lua_setallocf) then Exit;
    if not Assigned(lua_getstack) then Exit;
    if not Assigned(lua_getinfo) then Exit;
    if not Assigned(lua_getlocal) then Exit;
    if not Assigned(lua_setlocal) then Exit;
    if not Assigned(lua_getupvalue) then Exit;
    if not Assigned(lua_setupvalue) then Exit;
    if not Assigned(lua_sethook) then Exit;
    if not Assigned(lua_gethook) then Exit;
    if not Assigned(lua_gethookmask) then Exit;
    if not Assigned(lua_gethookcount) then Exit;
    if not Assigned(lua_upvalueid) then Exit;
    if not Assigned(lua_upvaluejoin) then Exit;
    if not Assigned(lua_version) then Exit;
    if not Assigned(lua_copy) then Exit;
    if not Assigned(lua_tonumberx) then Exit;
    if not Assigned(lua_tointegerx) then Exit;
    if not Assigned(lua_isyieldable) then Exit;
    if not Assigned(luaL_openlib) then Exit;
    if not Assigned(luaL_register) then Exit;
    if not Assigned(luaL_getmetafield) then Exit;
    if not Assigned(luaL_callmeta) then Exit;
    if not Assigned(luaL_typerror) then Exit;
    if not Assigned(luaL_argerror) then Exit;
    if not Assigned(luaL_checklstring) then Exit;
    if not Assigned(luaL_optlstring) then Exit;
    if not Assigned(luaL_checknumber) then Exit;
    if not Assigned(luaL_optnumber) then Exit;
    if not Assigned(luaL_checkinteger) then Exit;
    if not Assigned(luaL_optinteger) then Exit;
    if not Assigned(luaL_checkstack) then Exit;
    if not Assigned(luaL_checktype) then Exit;
    if not Assigned(luaL_checkany) then Exit;
    if not Assigned(luaL_newmetatable) then Exit;
    if not Assigned(luaL_checkudata) then Exit;
    if not Assigned(luaL_where) then Exit;
    if not Assigned(luaL_error) then Exit;
    if not Assigned(luaL_checkoption) then Exit;
    if not Assigned(luaL_fileresult) then Exit;
    if not Assigned(luaL_execresult) then Exit;
    if not Assigned(luaL_loadfilex) then Exit;
    if not Assigned(luaL_loadbufferx) then Exit;
    if not Assigned(luaL_traceback) then Exit;
    if not Assigned(luaL_testudata) then Exit;
    if not Assigned(luaL_setmetatable) then Exit;
    if not Assigned(luaL_ref) then Exit;
    if not Assigned(luaL_unref) then Exit;
    if not Assigned(luaL_loadfile) then Exit;
    if not Assigned(luaL_loadbuffer) then Exit;
    if not Assigned(luaL_loadstring) then Exit;
    if not Assigned(luaL_newstate) then Exit;
    if not Assigned(luaL_gsub) then Exit;
    if not Assigned(luaL_findtable) then Exit;
    if not Assigned(luaL_buffinit) then Exit;
    if not Assigned(luaL_prepbuffer) then Exit;
    if not Assigned(luaL_addlstring) then Exit;
    if not Assigned(luaL_addstring) then Exit;
    if not Assigned(luaL_addvalue) then Exit;
    if not Assigned(luaL_pushresult) then Exit;
    if not Assigned(luaopen_base) then Exit;
    if not Assigned(luaopen_table) then Exit;
    if not Assigned(luaopen_io) then Exit;
    if not Assigned(luaopen_string) then Exit;
    if not Assigned(luaopen_math) then Exit;
    if not Assigned(luaopen_debug) then Exit;
    if not Assigned(luaopen_package) then Exit;
    if not Assigned(luaopen_bit) then Exit;
    if not Assigned(luaopen_jit) then Exit;
    if not Assigned(luaopen_ffi) then Exit;
    if not Assigned(luaopen_string_buffer) then Exit;
    if not Assigned(luaL_openlibs) then Exit;

    Result := True;

    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
end;

procedure LuaDeInit;
begin
    luaL_setfuncs_ := nil;
    lua_newstate := nil;
    lua_close := nil;
    lua_newthread := nil;
    lua_atpanic := nil;
    lua_gettop := nil;
    lua_settop := nil;
    lua_pushvalue := nil;
    lua_remove := nil;
    lua_insert := nil;
    lua_replace := nil;
    lua_checkstack := nil;
    lua_xmove := nil;
    lua_isnumber := nil;
    lua_isstring := nil;
    lua_iscfunction := nil;
    lua_isuserdata := nil;
    lua_type := nil;
    lua_typename := nil;
    lua_equal := nil;
    lua_rawequal := nil;
    lua_lessthan := nil;
    lua_tonumber := nil;
    lua_tointeger := nil;
    lua_toboolean := nil;
    lua_tolstring := nil;
    lua_objlen := nil;
    lua_tocfunction := nil;
    lua_touserdata := nil;
    lua_tothread := nil;
    lua_topointer := nil;
    lua_pushnil := nil;
    lua_pushnumber := nil;
    lua_pushinteger := nil;
    lua_pushlstring := nil;
    lua_pushstring_ := nil;
    lua_pushvfstring := nil;
    lua_pushfstring := nil;
    lua_pushcclosure := nil;
    lua_pushboolean := nil;
    lua_pushlightuserdata := nil;
    lua_pushthread := nil;
    lua_gettable := nil;
    lua_getfield := nil;
    lua_rawget := nil;
    lua_rawgeti := nil;
    lua_createtable := nil;
    lua_newuserdata := nil;
    lua_getmetatable := nil;
    lua_getfenv := nil;
    lua_settable := nil;
    lua_setfield := nil;
    lua_rawset := nil;
    lua_rawseti := nil;
    lua_setmetatable := nil;
    lua_setfenv := nil;
    lua_call := nil;
    lua_pcall := nil;
    lua_cpcall := nil;
    lua_load := nil;
    lua_dump := nil;
    lua_yield := nil;
    lua_resume := nil;
    lua_status := nil;
    lua_gc := nil;
    lua_error := nil;
    lua_next := nil;
    lua_concat := nil;
    lua_getallocf := nil;
    lua_setallocf := nil;
    lua_getstack := nil;
    lua_getinfo := nil;
    lua_getlocal := nil;
    lua_setlocal := nil;
    lua_getupvalue := nil;
    lua_setupvalue := nil;
    lua_sethook := nil;
    lua_gethook := nil;
    lua_gethookmask := nil;
    lua_gethookcount := nil;
    lua_upvalueid := nil;
    lua_upvaluejoin := nil;
    lua_version := nil;
    lua_copy := nil;
    lua_tonumberx := nil;
    lua_tointegerx := nil;
    lua_isyieldable := nil;
    luaL_openlib := nil;
    luaL_register := nil;
    luaL_getmetafield := nil;
    luaL_callmeta := nil;
    luaL_typerror := nil;
    luaL_argerror := nil;
    luaL_checklstring := nil;
    luaL_optlstring := nil;
    luaL_checknumber := nil;
    luaL_optnumber := nil;
    luaL_checkinteger := nil;
    luaL_optinteger := nil;
    luaL_checkstack := nil;
    luaL_checktype := nil;
    luaL_checkany := nil;
    luaL_newmetatable := nil;
    luaL_checkudata := nil;
    luaL_where := nil;
    luaL_error := nil;
    luaL_checkoption := nil;
    luaL_fileresult := nil;
    luaL_execresult := nil;
    luaL_loadfilex := nil;
    luaL_loadbufferx := nil;
    luaL_traceback := nil;
    luaL_testudata := nil;
    luaL_setmetatable := nil;
    luaL_ref := nil;
    luaL_unref := nil;
    luaL_loadfile := nil;
    luaL_loadbuffer := nil;
    luaL_loadstring := nil;
    luaL_newstate := nil;
    luaL_gsub := nil;
    luaL_findtable := nil;
    luaL_buffinit := nil;
    luaL_prepbuffer := nil;
    luaL_addlstring := nil;
    luaL_addstring := nil;
    luaL_addvalue := nil;
    luaL_pushresult := nil;
    luaopen_base := nil;
    luaopen_table := nil;
    luaopen_io := nil;
    luaopen_string := nil;
    luaopen_math := nil;
    luaopen_debug := nil;
    luaopen_package := nil;
    luaopen_bit := nil;
    luaopen_jit := nil;
    luaopen_ffi := nil;
    luaopen_string_buffer := nil;
    luaL_openlibs := nil;

    if LuaLibHandle <> 0 then FreeLibrary(LuaLibHandle);
end;

(******************************************************************************
===============================================================================
LuaJIT -- a Just-In-Time Compiler for Lua. https://luajit.org/

Copyright (C) 2005-2023 Mike Pall. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

[ MIT license: https://www.opensource.org/licenses/mit-license.php ]

===============================================================================
[ LuaJIT includes code from Lua 5.1/5.2, which has this license statement: ]

Copyright (C) 1994-2012 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

===============================================================================
[ LuaJIT includes code from dlmalloc, which has this license statement: ]

This is a version (aka dlmalloc) of malloc/free/realloc written by
Doug Lea and released to the public domain, as explained at
https://creativecommons.org/licenses/publicdomain

===============================================================================
******************************************************************************)

end.
