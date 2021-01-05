(*===========================================================================*)
(*===========================================================================*)
(*	uberSpark bridge module interface specification		 *)
(*	author: amit vasudevan (amitvasudevan@acm.org)							 *)
(*===========================================================================*)
(*===========================================================================*)


(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* type definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)



(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* general submodules *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

module Container : sig

	val build_image : string -> string -> int
	val list_images : string -> unit 
	val run_image : ?context_path_builddir:string -> string -> string -> string -> int
    
end

module Native : sig

	val run_shell_command : ?context_path_builddir:string -> string -> string -> string -> int

end


(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* interface definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

val dump : string -> ?bridge_exectype:string -> string -> unit
val remove : string -> unit
val bridge_parameter_to_string :
	?separator:string -> 
	?prefix:string -> 
	string list ->
	string




(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* class definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

class bridge_object :
object

	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t 
	val json_node_uberspark_bridge_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t
	
	method load_from_json : Yojson.Basic.json ->  bool
	method load_from_file : string -> bool
	method load : string -> bool
	method store_to_file : string -> bool
	method store : unit -> bool
	method build : unit -> bool
	method invoke :  ?gen_obj:bool -> 
	?context_path_builddir:string -> 
	string list -> 
	string list -> 
	string -> 
	bool

end






(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* bridge submodules *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

module Cc : sig

	(*--------------------------------------------------------------------------*)
	(* cc-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_cc_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t 


	(*--------------------------------------------------------------------------*)
	(* cc-bridge interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	(*val invoke :  ?gen_obj:bool -> ?gen_asm:bool -> ?context_path_builddir:string -> string list -> string list -> string -> bool*)
	val invoke :  ?gen_obj:bool -> 
	?context_path_builddir:string -> 
	string list -> 
	string list -> 
	string -> 
	bool


end


module As : sig

	(*--------------------------------------------------------------------------*)
	(* as-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_as_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t


	(*--------------------------------------------------------------------------*)
	(* as-bridge interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	
	val invoke :
	?context_path_builddir:string -> 
	(string * string) list ->
	bool

end



module Casm : sig

	(*--------------------------------------------------------------------------*)
	(* as-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_casm_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t


	(*--------------------------------------------------------------------------*)
	(* as-bridge interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	val invoke :  ?gen_obj:bool -> 
	?context_path_builddir:string -> 
	string list -> 
	string list -> 
	string -> 
	bool

end


module Ld : sig

	(*--------------------------------------------------------------------------*)
	(* ld-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_ld_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t


	(*--------------------------------------------------------------------------*)
	(* interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	
	
	val invoke : 
		?context_path_builddir : string -> 
		string ->
		string ->
		string ->
		string ->
		string list ->
		string ->
		bool


end


module Vf : sig

	(*--------------------------------------------------------------------------*)
	(* vf-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_vf_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t


	(*--------------------------------------------------------------------------*)
	(* interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	val invoke : 
		?context_path_builddir : string -> 
		string list ->
		string list ->
		string ->
		bool

end

module Loader : sig

	(*--------------------------------------------------------------------------*)
	(* loader-bridge data variables *)
	(*--------------------------------------------------------------------------*)
	val json_node_uberspark_manifest_var: Uberspark_manifest.json_node_uberspark_manifest_t
	val json_node_uberspark_bridge_loader_var: Uberspark_manifest.Bridge.json_node_uberspark_bridge_t


	(*--------------------------------------------------------------------------*)
	(* interfaces *)
	(*--------------------------------------------------------------------------*)
	val load_from_json : Yojson.Basic.json ->  bool
	val load_from_file : string -> bool
	val load : string -> bool
	val store_to_file : string -> bool
	val store : unit -> bool
	val build : unit -> bool
	val invoke :  ?gen_obj:bool -> 
	?context_path_builddir:string -> 
	string list -> 
	string list -> 
	string -> 
	bool

end



(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* interface definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

val initialize_from_config : unit -> bool
