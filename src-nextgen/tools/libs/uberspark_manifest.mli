(****************************************************************************)
(****************************************************************************)
(* uberSpark manifest interface *)
(* author: amit vasudevan (amitvasudevan@acm.org) *)
(****************************************************************************)
(****************************************************************************)


(****************************************************************************)
(* manifest node types *)
(****************************************************************************)

(* uberspark generic manifest header *)
type hdr_t =
{
	mutable f_coss_version : string;			
	mutable f_mftype : string;
	mutable f_uberspark_min_version   : string;
  mutable f_uberspark_max_version : string;
}


(****************************************************************************)
(* manifest parse interfaces *)
(****************************************************************************)
val parse_uberspark_hdr : Yojson.Basic.t -> hdr_t -> bool
val get_manifest_json : ?check_header:bool -> string -> bool * Yojson.Basic.t


(****************************************************************************)
(* manifest write interfaces *)
(****************************************************************************)
val write_prologue : ?prologue_str:string -> out_channel -> bool
val write_uberspark_hdr : ?continuation:bool -> out_channel -> hdr_t -> bool
val write_epilogue : ?epilogue_str:string -> out_channel -> bool



(****************************************************************************)
(* submodules *)
(****************************************************************************)

module Config : sig

  (****************************************************************************)
  (* manifest node types *)
  (****************************************************************************)

  (* config-hdr node type *)
  type config_hdr_t =
  {
      mutable namespace    : string;			
  }

  (* config-settings node type *)
  type config_settings_t = 
  {
    (* environment related settings *)
    mutable env_home_dir : string;

    (* uobj/uobjcoll binary related configuration settings *)	
    mutable binary_page_size : int;
    mutable binary_uobj_section_alignment : int;
    mutable binary_uobj_default_section_size : int;
    mutable binary_uobj_default_load_addr : int;
    mutable binary_uobj_default_size : int;

    (* bridge related configuration settings *)	
    mutable bridge_cc_bridge : string;

  }


  (****************************************************************************)
  (* manifest parse interfaces *)
  (****************************************************************************)
  val parse_config_hdr : Yojson.Basic.t -> config_hdr_t -> bool
  val parse_config_settings : Yojson.Basic.t -> config_settings_t -> bool


  (****************************************************************************)
  (* manifest write interfaces *)
  (****************************************************************************)
  val write_config_hdr : ?continuation:bool -> out_channel -> config_hdr_t -> bool
  val write_config_settings : ?continuation:bool -> out_channel -> config_settings_t -> bool


end


module Uobj : sig
  type uobj_hdr_t =
    {
      mutable f_namespace    : string;			
      mutable f_platform	   : string;
      mutable f_arch	       : string;
      mutable f_cpu				   : string;
    }


  val parse_uobj_hdr : Yojson.Basic.t -> uobj_hdr_t -> bool
  
end


module Uobjslt : sig
  type uobjslt_hdr_t =
    {
      mutable f_namespace    : string;			
      mutable f_platform	   : string;
      mutable f_arch	       : string;
      mutable f_cpu				   : string;
    }


  val parse_uobjslt_hdr : Yojson.Basic.t -> uobjslt_hdr_t -> bool
  val parse_uobjslt_trampolinecode : Yojson.Basic.t -> bool * string
  val parse_uobjslt_trampolinedata : Yojson.Basic.t -> bool * string
end

