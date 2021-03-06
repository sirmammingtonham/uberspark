(*===========================================================================*)
(*===========================================================================*)
(*	uberSpark uberobject verification and build interface 	             	 *)
(*	implementation															 *)
(*	author: amit vasudevan (amitvasudevan@acm.org)							 *)
(*===========================================================================*)
(*===========================================================================*)

open Str

		
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* type definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)

type publicmethod_info_t =
{
	mutable f_uobjpminfo			: Uberspark_manifest.Uobj.json_node_uberspark_uobj_publicmethods_t;
	mutable f_uobjinfo    			: Defs.Basedefs.uobjinfo_t;			
};;


type slt_info_t = 
{
	(* intrauobjcoll canonical publicmethod name to sentinel type list mapping *)
	mutable f_intrauobjcoll_callees_sentinel_type_hashtbl : (string, string list) Hashtbl.t;

	(* intrauobjcoll canonical publicmethod sentinel name to sentinel address mapping *)
	mutable f_intrauobjcoll_callees_sentinel_address_hashtbl : (string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t; 

	(* indexed by canonical publicmethod name *)
	mutable f_interuobjcoll_callees_sentinel_type_hashtbl : (string, string list) Hashtbl.t;

	(* indexed by canonical publicmethod sentinel name *)
	mutable f_interuobjcoll_callees_sentinel_address_hashtbl : (string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t; 

	(* indexed by canonical legacy callee name *)
	mutable f_legacy_callees_sentinel_type_hashtbl : (string, string list) Hashtbl.t;

	(* indexed by canonical legacy callee sentinel name *)
	mutable f_legacy_callees_sentinel_address_hashtbl : (string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t; 
};;



(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* class definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)


class uobject 
	= object(self)

	(*val log_tag = "Usuobj";*)
	val d_ltag = "Usuobj";

	val d_mf_filename = ref "";
	method get_d_mf_filename = !d_mf_filename;
	method set_d_mf_filename (mf_filename : string) = 
		d_mf_filename := mf_filename;
		()
	;

	val d_path_to_mf_filename = ref "";
	method get_d_path_to_mf_filename = !d_path_to_mf_filename;
	method set_d_path_to_mf_filename (path_to_mf_filename : string) = 
		d_path_to_mf_filename := path_to_mf_filename;
		()
	;

	val d_path_ns = ref "";
	method get_d_path_ns = !d_path_ns;

	val d_builddir = ref "";
	method get_d_builddir = !d_builddir;
	method set_d_builddir (builddir : string) = 
		d_builddir := builddir;
		()
	;


	(* uobj manifest file top-level json *)
	val d_mf_json : Yojson.Basic.t ref = ref `Null;

	(* uobj manifest uberspark-uobj json node var *)
	val json_node_uberspark_uobj_var : Uberspark_manifest.Uobj.json_node_uberspark_uobj_t =
		{f_namespace = ""; f_platform = ""; f_arch = ""; f_cpu = ""; 
		f_sources = {f_h_files= []; f_c_files = []; f_casm_files = []; f_asm_files = [];};
		f_publicmethods = []; f_intrauobjcoll_callees = []; f_interuobjcoll_callees = [];
		f_legacy_callees = []; f_sections = []; 
		};


	val d_mf_json_node_uberspark_uobjslt_var : Uberspark_manifest.Uobjslt.json_node_uberspark_uobjslt_t = 
		{f_namespace = ""; f_platform = ""; f_arch = ""; f_cpu = ""; f_addr_size=0;
		 f_code_directxfer = ""; f_code_indirectxfer = ""; f_code_addrdef = ""; };

	method get_d_publicmethods_assoc_list = json_node_uberspark_uobj_var.f_publicmethods;



	val d_publicmethods_hashtbl = ((Hashtbl.create 32) : ((string, Uberspark_manifest.Uobj.json_node_uberspark_uobj_publicmethods_t)  Hashtbl.t)); 
	method get_d_publicmethods_hashtbl = d_publicmethods_hashtbl;

	val d_intrauobjcoll_callees_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t)); 
	method get_d_intrauobjcoll_callees_hashtbl = d_intrauobjcoll_callees_hashtbl;

	val d_interuobjcoll_callees_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t)); 
	method get_d_interuobjcoll_callees_hashtbl = d_interuobjcoll_callees_hashtbl;

	val d_legacy_callees_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t)); 
	method get_d_legacy_callees_hashtbl = d_legacy_callees_hashtbl;

	(* association list of default uobj binary image sections; indexed by section name *)		
	val d_default_sections_list : (string * Defs.Basedefs.section_info_t) list ref = ref []; 
	method get_d_default_sections_list_ref = d_default_sections_list;
	method get_d_default_sections_list_val = !d_default_sections_list;


	(* association list of uobj public methods sections; indexed by section name *)		
	val d_publicmethods_sections_list : (string * Defs.Basedefs.section_info_t) list ref = ref []; 
	method get_d_publicmethods_sections_list_ref = d_publicmethods_sections_list;
	method get_d_publicmethods_sections_list_val = !d_publicmethods_sections_list;


	(* association list of uobj binary image sections with memory map info; indexed by section name *)		
	val d_memorymapped_sections_list : (string * Defs.Basedefs.section_info_t) list ref = ref []; 
	method get_d_memorymapped_sections_list_ref = d_memorymapped_sections_list;
	method get_d_memorymapped_sections_list_val = !d_memorymapped_sections_list;


	val d_target_def: Defs.Basedefs.target_def_t = {
		f_platform = ""; 
		f_arch = ""; 
		f_cpu = "";
	};
	method get_d_target_def = d_target_def;
	method set_d_target_def 
		(target_def: Defs.Basedefs.target_def_t) = 
		d_target_def.f_platform <- target_def.f_platform;
		d_target_def.f_arch <- target_def.f_arch;
		d_target_def.f_cpu <- target_def.f_cpu;
		()
	;
		


	(* uobj binary image load address *)
	val d_load_addr = ref Uberspark_config.json_node_uberspark_config_var.uobj_binary_image_load_address;
	method get_d_load_addr = !d_load_addr;
	method set_d_load_addr load_addr = (d_load_addr := load_addr);
	
	(* uobj binary image size; will be overwritten with actual size using alignment if uniform_size=false  *)
	val d_size = ref Uberspark_config.json_node_uberspark_config_var.uobj_binary_image_size; 
	method get_d_size = !d_size;
	method set_d_size size = (d_size := size);

	(* uobj binary image uniform size flag *)
	val d_uniform_size = ref Uberspark_config.json_node_uberspark_config_var.uobj_binary_image_uniform_size; 
	method get_d_uniform_size = !d_uniform_size;
	method set_d_uniform_size uniform_size = (d_uniform_size := uniform_size);

	(* uobj binary image alignment *)
	val d_alignment = ref Uberspark_config.json_node_uberspark_config_var.uobj_binary_image_alignment; 
	method get_d_alignment = !d_alignment;
	method set_d_alignment alignment = (d_alignment := alignment);


	(* uobj sentinel linkage table info  -- updated by uobjcoll build *)
	val d_slt_info : slt_info_t = {
		f_intrauobjcoll_callees_sentinel_type_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t));
		f_intrauobjcoll_callees_sentinel_address_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t));
		f_interuobjcoll_callees_sentinel_type_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t));
		f_interuobjcoll_callees_sentinel_address_hashtbl =((Hashtbl.create 32) : ((string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t));
		f_legacy_callees_sentinel_type_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t));
		f_legacy_callees_sentinel_address_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t));  
	};
	method get_d_slt_info = d_slt_info;
	method set_d_slt_info 
		(slt_info: slt_info_t) = 
		d_slt_info.f_intrauobjcoll_callees_sentinel_type_hashtbl <- slt_info.f_intrauobjcoll_callees_sentinel_type_hashtbl;
		d_slt_info.f_intrauobjcoll_callees_sentinel_address_hashtbl <- slt_info.f_intrauobjcoll_callees_sentinel_address_hashtbl; 
		d_slt_info.f_interuobjcoll_callees_sentinel_type_hashtbl <- slt_info.f_interuobjcoll_callees_sentinel_type_hashtbl; 
		d_slt_info.f_interuobjcoll_callees_sentinel_address_hashtbl <- slt_info.f_interuobjcoll_callees_sentinel_address_hashtbl;
		d_slt_info.f_legacy_callees_sentinel_type_hashtbl <- slt_info.f_legacy_callees_sentinel_type_hashtbl; 
		d_slt_info.f_legacy_callees_sentinel_address_hashtbl <- slt_info.f_legacy_callees_sentinel_address_hashtbl; 
		()
	;

	(* uobj slt codegen info list for interuobjcoll callees *)
	val d_interuobjcoll_callees_slt_codegen_info_list : Uberspark_codegen.Uobj.slt_codegen_info_t list ref = ref [];

	(* uobj slt codegen info list for intrauobjcoll callees *)
	val d_intrauobjcoll_callees_slt_codegen_info_list : Uberspark_codegen.Uobj.slt_codegen_info_t list ref = ref [];

	(* uobj slt codegen info list for legacy callees *)
	val d_legacy_callees_slt_codegen_info_list : Uberspark_codegen.Uobj.slt_codegen_info_t list ref = ref [];

	(* uobj slt indirect xfer table assoc list for interuobjcoll callees indexed by canonical pm sentinel name *)
	val d_interuobjcoll_callees_slt_indirect_xfer_table_assoc_list : (string * Defs.Basedefs.slt_indirect_xfer_table_info_t) list ref = ref []; 
	
	(* uobj slt indirect xfer table assoc list for intrauobjcoll callees indexed by canonical pm sentinel name *)
	val d_intrauobjcoll_callees_slt_indirect_xfer_table_assoc_list : (string * Defs.Basedefs.slt_indirect_xfer_table_info_t) list ref = ref []; 

	(* uobj slt indirect xfer table assoc list for legacy callees indexed by canonical pm sentinel name *)
	val d_legacy_callees_slt_indirect_xfer_table_assoc_list : (string * Defs.Basedefs.slt_indirect_xfer_table_info_t) list ref = ref []; 



	(*--------------------------------------------------------------------------*)
	(* parse uobj manifest *)
	(* usmf_filename = canonical uobj manifest filename *)
	(*--------------------------------------------------------------------------*)
	method parse_manifest 
		()
		: bool =

		(* read manifest JSON *)
		let (rval, mf_json) = (Uberspark_manifest.get_json_for_manifest 
			(self#get_d_path_to_mf_filename ^ "/" ^ self#get_d_mf_filename) 
			) in
		
		if (rval == false) then (false)
		else

		(* store manifest JSON *)
		let dummy = 0 in begin
		d_mf_json := mf_json;
		end;

		(* parse uberspark-uobj node *)
		let rval = (Uberspark_manifest.Uobj.json_node_uberspark_uobj_to_var mf_json
				json_node_uberspark_uobj_var) in

		if (rval == false) then (false)
		else

		let dummy = 0 in begin
		(* generate publicmethods hashtable *)
		List.iter ( fun (x,y) -> 
			Hashtbl.add d_publicmethods_hashtbl x y;
		) json_node_uberspark_uobj_var.f_publicmethods;

		(* generate intrauobjcoll-callees hashtable *)
		List.iter ( fun (x,y) -> 
			Hashtbl.add d_intrauobjcoll_callees_hashtbl x y;
		) json_node_uberspark_uobj_var.f_intrauobjcoll_callees;

		(* generate interuobjcoll-callees hashtable *)
		List.iter ( fun (x,y) -> 
			Hashtbl.add d_interuobjcoll_callees_hashtbl x y;
		) json_node_uberspark_uobj_var.f_interuobjcoll_callees;

		(* generate legacy-callees hashtable *)
		List.iter ( fun (x,y) -> 
			Hashtbl.add d_legacy_callees_hashtbl x y;
		) json_node_uberspark_uobj_var.f_legacy_callees;
		end;


		let dummy=0 in begin
			d_path_ns := (Uberspark_namespace.get_namespace_staging_dir_prefix ())  ^ "/" ^ json_node_uberspark_uobj_var.f_namespace;
		end;

		let dummy = 0 in
			begin
				Uberspark_logger.log "total sources: h files=%u, c files=%u, casm files=%u, asm files=%u" 
					(List.length json_node_uberspark_uobj_var.f_sources.f_h_files)
					(List.length json_node_uberspark_uobj_var.f_sources.f_c_files)
					(List.length json_node_uberspark_uobj_var.f_sources.f_casm_files)
					(List.length json_node_uberspark_uobj_var.f_sources.f_asm_files);
			end;


		let dummy = 0 in
			begin
				Uberspark_logger.log "total public methods:%u,%u" (Hashtbl.length self#get_d_publicmethods_hashtbl)
					(List.length json_node_uberspark_uobj_var.f_publicmethods); 
			end;

		let dummy = 0 in
			begin
				Uberspark_logger.log "list of uobj-intrauobjcoll-callees follows:";

				Hashtbl.iter (fun key value  ->
					Uberspark_logger.log "uobj=%s; callees=%u" key (List.length value);
				) self#get_d_intrauobjcoll_callees_hashtbl;
			end;

		let dummy = 0 in
			begin
				Uberspark_logger.log "total interuobjcoll callees=%u" (Hashtbl.length self#get_d_interuobjcoll_callees_hashtbl);
			end;

		let dummy = 0 in
			begin
				Uberspark_logger.log "total legacy callees=%u" (Hashtbl.length self#get_d_legacy_callees_hashtbl);
			end;


		let dummy = 0 in
		if (rval == true) then
			begin
				Uberspark_logger.log "binary sections override:%u" (List.length json_node_uberspark_uobj_var.f_sections);								
			end;

		(true)
	;




		



	(*--------------------------------------------------------------------------*)
	(* parse sentinel linkage manifest *)
	(*--------------------------------------------------------------------------*)
	method parse_manifest_slt	
		= 
		let retval = ref false in 	
		let target_def = self#get_d_target_def in	
		let uobjslt_filename = ((Uberspark_namespace.get_namespace_staging_dir_prefix ()) ^ "/" ^ Uberspark_namespace.namespace_root ^ "/" ^ Uberspark_namespace.namespace_uobjslt ^ "/" ^
			target_def.f_arch ^ "/" ^ target_def.f_cpu ^ "/" ^
			Uberspark_namespace.namespace_root_mf_filename) in 

		let (rval, abs_uobjslt_filename) = (Uberspark_osservices.abspath uobjslt_filename) in
		if(rval == true) then
		begin
			Uberspark_logger.log "reading slt manifest from:%s" abs_uobjslt_filename;

			(* read manifest JSON *)
			let (rval, mf_json) = (Uberspark_manifest.get_json_for_manifest abs_uobjslt_filename) in
			if(rval == true) then
			begin

				(* convert to var *)
				let rval =	(Uberspark_manifest.Uobjslt.json_node_uberspark_uobjslt_to_var mf_json d_mf_json_node_uberspark_uobjslt_var) in
				if rval then
				begin
					retval := true;

				end;
			end;
		end;

		(!retval)
	;


	(*--------------------------------------------------------------------------*)
	(* overlay uobj config settings if any *)
	(*--------------------------------------------------------------------------*)
	method overlay_config_settings 
		()
		: bool =

		(* parse, load and overlay config-settings node, if one is present *)
		if (Uberspark_config.load_from_json !d_mf_json) then begin
			(true) (* loaded and overlaid config-settings from uobj manifest *)
		end else begin
			(false) (* uobj manifest did not have config-settings specified *)
		end
	;


	(*--------------------------------------------------------------------------*)
	(* consolidate sections with memory map *)
	(* update uobj size (d_size) accordingly and return the size *)
	(*--------------------------------------------------------------------------*)
	method consolidate_sections_with_memory_map
		()
		: int  
		=

		let uobj_section_load_addr = ref 0 in
		(* TBD: we need to handle non-uniform uobj size, in which case we will only be an alignment value 
			and we need to revise uobjsize comparision to alignment comparisons
		*)
		let uobjsize = self#get_d_size in
		let uobj_load_addr = self#get_d_load_addr in

		(* clear out memory mapped sections list and set initial load address *)
		uobj_section_load_addr := self#get_d_load_addr;
		d_memorymapped_sections_list := []; 
		
		(* iterate over default sections *)
		List.iter (fun (key, (x:Defs.Basedefs.section_info_t))  ->
			(* compute and round up section size to section alignment *)
			let remainder_size = (x.usbinformat.f_size mod Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment) in
			let padding_size = ref 0 in
				if remainder_size > 0 then
					begin
						padding_size := Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment - remainder_size;
					end
				else
					begin
						padding_size := 0;
					end
				;
			let section_size = (x.usbinformat.f_size + !padding_size) in 


			d_memorymapped_sections_list := !d_memorymapped_sections_list @ [ (key, 
				{ f_name = x.f_name;	
					f_subsection_list = x.f_subsection_list;	
					usbinformat = { f_type=x.usbinformat.f_type; 
													f_prot=0; 
													f_size = section_size;
													f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
													f_addr_start = !uobj_section_load_addr; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				}) ];


			Uberspark_logger.log "section at address 0x%08x, size=0x%08x padding=0x%08x" !uobj_section_load_addr section_size !padding_size;

			(* if this section is for a public method, then update publicmethods hashtable with address *)
			if x.usbinformat.f_type == Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_PMINFO then begin
				let pm_name = (Str.string_after x.f_name 8) in  (* grab public method name after uobj_pm_ *)
				Uberspark_logger.log ~lvl:Uberspark_logger.Debug "section is for publicmethod: name=%s" pm_name;
			    if (Hashtbl.mem self#get_d_publicmethods_hashtbl pm_name) then begin
					let pm_info = (Hashtbl.find self#get_d_publicmethods_hashtbl pm_name) in
						pm_info.f_addr <- !uobj_section_load_addr;
					Hashtbl.replace self#get_d_publicmethods_hashtbl pm_name pm_info;
					Uberspark_logger.log ~lvl:Uberspark_logger.Debug "updated publicmethod address as 0x%08x" pm_info.f_addr;
		    	end else begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Warn "unable to match public method name to section definition!";
		    	end
			    ;
			end;

			(* compute next section load address *)
			uobj_section_load_addr := !uobj_section_load_addr + section_size;

		)self#get_d_default_sections_list_val;


		(* iterate over manifest sections *)
		List.iter (fun (key, (x:Defs.Basedefs.section_info_t))  ->
			(* compute and round up section size to section alignment *)
			let remainder_size = (x.usbinformat.f_size mod Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment) in
			let padding_size = ref 0 in
				if remainder_size > 0 then
					begin
						padding_size := Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment - remainder_size;
					end
				else
					begin
						padding_size := 0;
					end
				;
			let section_size = (x.usbinformat.f_size + !padding_size) in 


			d_memorymapped_sections_list := !d_memorymapped_sections_list @ [ (key, 
				{ f_name = x.f_name;	
					f_subsection_list = x.f_subsection_list;	
					usbinformat = { f_type=x.usbinformat.f_type; 
													f_prot=0; 
													f_size = section_size;
													f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
													f_addr_start = !uobj_section_load_addr; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				}) ];

			Uberspark_logger.log "section at address 0x%08x, size=0x%08x padding=0x%08x" !uobj_section_load_addr section_size !padding_size;
			uobj_section_load_addr := !uobj_section_load_addr + section_size;

		)json_node_uberspark_uobj_var.f_sections;

		
		if (self#get_d_uniform_size) then begin
			(* uniform uobj binary image size *)
			
			(* check to see if the uobj sections fit neatly into uobj size *)
			(* if not, add a filler section to pad it to uobj size *)
			if (!uobj_section_load_addr - uobj_load_addr) > uobjsize then
				begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Error "uobj total section sizes (0x%08x) span beyond uobj size (0x%08x)!" (!uobj_section_load_addr - uobj_load_addr) uobjsize;
					ignore(exit 1);
				end
			;	

			if (!uobj_section_load_addr - uobj_load_addr) < uobjsize then
				begin
					(* add padding section *)
					d_memorymapped_sections_list := !d_memorymapped_sections_list @ [ ("usuobj_padding", 
						{ f_name = "usuobj_padding";	
							f_subsection_list = [ ];	
							usbinformat = { f_type = Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_PADDING;
															f_prot=0; 
															f_size = (uobjsize - (!uobj_section_load_addr - uobj_load_addr));
															f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
															f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
															f_addr_start = !uobj_section_load_addr; 
															f_addr_file = 0;
															f_reserved = 0;
														};
						}) ];
				end
			;	

		end else begin
			(* uobj binary image sizes within the collection are not uniform *)
			
			if (!uobj_section_load_addr mod self#get_d_alignment) > 0 then begin
				(* uobj_section_load_addr is __not__ aligned at uobj_binary_image_alignment *)
				(* add padding section *)
				d_memorymapped_sections_list := !d_memorymapped_sections_list @ [ ("usuobj_padding", 
					{ f_name = "uobj_padding";	
						f_subsection_list = [ ];	
						usbinformat = { f_type = Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_PADDING;
										f_prot=0; 
										f_size = (self#get_d_alignment - (!uobj_section_load_addr mod self#get_d_alignment));
										f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
										f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
										f_addr_start = !uobj_section_load_addr; 
										f_addr_file = 0;
										f_reserved = 0;
						};
					} )];

				(* update uobj size *)
				self#set_d_size ((!uobj_section_load_addr + (self#get_d_alignment - (!uobj_section_load_addr mod self#get_d_alignment))) - self#get_d_load_addr);

			end else begin
				(* uobj_section_load_addr is aligned at uobj_binary_image_alignment *)
				(* we don't need to do anything *)
			end;

		end;
					
		(self#get_d_size)
	;


	(*--------------------------------------------------------------------------*)
	(* add default uobj binary sections *)
	(*--------------------------------------------------------------------------*)
	method add_default_uobj_binary_sections	
		()
		: unit =
		
		(* start with uobj state save area section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_ssa", {
			f_name = "uobj_ssa";	
			f_subsection_list = [ ".uobj_ssa" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_SSA; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];

		(* create sections for each public method *)
		Hashtbl.iter (fun (pm_name:string) (pm_info:Uberspark_manifest.Uobj.json_node_uberspark_uobj_publicmethods_t)  ->
			let section_name = ("uobj_pm_" ^ pm_name) in 
			d_default_sections_list := !d_default_sections_list @ [ (section_name, {
				f_name = section_name;	
				f_subsection_list = [ "." ^ section_name ];	
				usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_PMINFO; 
								f_prot=0; 
								f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
								f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
								f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
								f_addr_start=0; 
								f_addr_file = 0;
								f_reserved = 0;
							};
			}) ];

		) self#get_d_publicmethods_hashtbl;
		

		(* intrauobjcoll callees slt code section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_intrauobjcoll_csltcode", {
			f_name = "uobj_intrauobjcoll_csltcode";	
			f_subsection_list = [ ".uobj_intrauobjcoll_csltcode" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_INTRAUOBJCOLL_CSLTCODE; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];

		(* intrauobjcoll callees slt data section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_intrauobjcoll_csltdata", {
			f_name = "uobj_intrauobjcoll_csltdata";	
			f_subsection_list = [ ".uobj_intrauobjcoll_csltdata" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_INTRAUOBJCOLL_CSLTDATA; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];


		(* interuobjcoll callees slt code section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_interuobjcoll_csltcode", {
			f_name = "uobj_interuobjcoll_csltcode";	
			f_subsection_list = [ ".uobj_interuobjcoll_csltcode" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_INTERUOBJCOLL_CSLTCODE; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];


		(* interuobjcoll callees slt data section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_interuobjcoll_csltdata", {
			f_name = "uobj_interuobjcoll_csltdata";	
			f_subsection_list = [ ".uobj_interuobjcoll_csltdata" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_INTERUOBJCOLL_CSLTDATA; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];


		(* legacy callees slt code section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_legacy_csltcode", {
			f_name = "uobj_legacy_csltcode";	
			f_subsection_list = [ ".uobj_legacy_csltcode" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_LEGACY_CSLTCODE; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];

		(* legacy callees slt data section *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_legacy_csltdata", {
			f_name = "uobj_legacy_csltdata";	
			f_subsection_list = [ ".uobj_legacy_csltdata" ];	
			usbinformat = { f_type= Defs.Binformat.const_USBINFORMAT_SECTION_TYPE_UOBJ_LEGACY_CSLTDATA; 
							f_prot=0; 
							f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
							f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
							f_addr_start=0; 
							f_addr_file = 0;
							f_reserved = 0;
						};
		}) ];


		(* uobj code, data, dmadata and stack sections follow *)
		d_default_sections_list := !d_default_sections_list @ [ ("uobj_code", {
				 f_name = "uobj_code";	
				f_subsection_list = [ ".text" ];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_CODE; 
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		d_default_sections_list := !d_default_sections_list @ [ ("uobj_rodata", {
			 f_name = "uobj_rodata";	
				f_subsection_list = [".rodata"];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_RODATA; 
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment;
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		d_default_sections_list := !d_default_sections_list @ [ ("uobj_rwdata", {
			 f_name = "uobj_rwdata";	
				f_subsection_list = [".data"; ".bss"];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_RWDATA; 
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment;
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		d_default_sections_list := !d_default_sections_list @ [ ("uobj_dmadata", {
			 f_name = "uobj_dmadata";	
				f_subsection_list = [".dmadata"];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_DMADATA;
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment;
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		d_default_sections_list := !d_default_sections_list @ [ ("uobj_ustack", {
			 f_name = "uobj_ustack";	
				f_subsection_list = [ ".ustack" ];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_USTACK; 
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment;
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		d_default_sections_list := !d_default_sections_list @ [ ("uobj_tstack", {
			 f_name = "uobj_tstack";	
				f_subsection_list = [ ".tstack"; ".stack" ];	
				usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_TSTACK; 
												f_prot=0; 
												f_size = Uberspark_config.json_node_uberspark_config_var.binary_uobj_default_section_size;
												f_aligned_at = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment;
												f_pad_to = Uberspark_config.json_node_uberspark_config_var.binary_uobj_section_alignment; 
												f_addr_start=0; 
												f_addr_file = 0;
												f_reserved = 0;
											};
		}) ];

		()
	;



	(*--------------------------------------------------------------------------*)
	(* prepare for slt code generation *)
	(*--------------------------------------------------------------------------*)
	method prepare_slt_codegen 
		(callees_slt_codegen_info_list : Uberspark_codegen.Uobj.slt_codegen_info_t list ref)
		(callees_slt_indirect_xfer_table_assoc_list : (string * Defs.Basedefs.slt_indirect_xfer_table_info_t) list ref) 
		(callees_sentinel_type_hashtbl : (string, string list)  Hashtbl.t)
		(callees_sentinel_address_hashtbl : (string, Defs.Basedefs.uobjcoll_sentinel_address_t)  Hashtbl.t)
		(callees_hashtbl : (string, string list)  Hashtbl.t)
		: unit =

		let slt_indirect_xfer_table_offset = ref 0 in
		
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "prepare_slt_codegen: start";
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "length of callees_sentinel_type_hashtbl=%u" (Hashtbl.length callees_sentinel_type_hashtbl);

  		Hashtbl.iter (fun (ns: string) (pm_name_list: string list)  ->
	        List.iter (fun (pm_name:string) -> 
				let ns_var = (Uberspark_namespace.get_variable_name_prefix_from_ns ns) in 
				let canonical_pm_name = (ns_var ^ "__" ^ pm_name) in
				let callees_sentinel_type_list = Hashtbl.find callees_sentinel_type_hashtbl canonical_pm_name in
				List.iter ( fun (sentinel_type: string) ->
					let canonical_pm_name_with_sentinel_suffix = (canonical_pm_name ^ "__" ^ sentinel_type) in  
					let pm_sentinel_addr = ref 0 in 
					let codegen_type = ref "" in 

					if sentinel_type = "call" then begin
						if (Hashtbl.mem callees_sentinel_address_hashtbl canonical_pm_name_with_sentinel_suffix) then begin
							pm_sentinel_addr := (Hashtbl.find callees_sentinel_address_hashtbl canonical_pm_name_with_sentinel_suffix).f_pm_addr;
							codegen_type := "direct";
						end else begin
							pm_sentinel_addr := 0;
							codegen_type := "indirect";
						end;
					end else begin
						if (Hashtbl.mem callees_sentinel_address_hashtbl canonical_pm_name_with_sentinel_suffix) then begin
							pm_sentinel_addr := (Hashtbl.find callees_sentinel_address_hashtbl canonical_pm_name_with_sentinel_suffix).f_sentinel_addr;
							codegen_type := "direct";
						end else begin
							pm_sentinel_addr := 0;
							codegen_type := "indirect";
						end;
					end;

					let slt_codegen_info : Uberspark_codegen.Uobj.slt_codegen_info_t = {
						f_canonical_pm_name = canonical_pm_name_with_sentinel_suffix;
						f_pm_sentinel_addr = !pm_sentinel_addr;
						f_codegen_type = !codegen_type;
						f_pm_sentinel_addr_loc = 0;
					} in


					if !codegen_type = "indirect" then begin
						let slt_indirect_xfer_table_entry : Defs.Basedefs.slt_indirect_xfer_table_info_t = {
							f_canonical_pm_name = canonical_pm_name;
							f_sentinel_type = sentinel_type;
							f_table_offset = !slt_indirect_xfer_table_offset;
							f_addr = !pm_sentinel_addr;
						} in

						callees_slt_indirect_xfer_table_assoc_list := !callees_slt_indirect_xfer_table_assoc_list @
							[ (canonical_pm_name_with_sentinel_suffix, slt_indirect_xfer_table_entry) ];

						slt_codegen_info.f_pm_sentinel_addr_loc <- !slt_indirect_xfer_table_offset;

						slt_indirect_xfer_table_offset := !slt_indirect_xfer_table_offset + d_mf_json_node_uberspark_uobjslt_var.f_addr_size;
					end;

					callees_slt_codegen_info_list := !callees_slt_codegen_info_list @ [ slt_codegen_info ];

					Uberspark_logger.log ~lvl:Uberspark_logger.Debug "added entry: name=%s, addr=0x%08x" 
						slt_codegen_info.f_canonical_pm_name slt_codegen_info.f_pm_sentinel_addr;

					(* if sentinel type is call, then add entry with just canonical_pm_name in addition *)
					if sentinel_type = "call" then begin
						let slt_codegen_info : Uberspark_codegen.Uobj.slt_codegen_info_t = {
							f_canonical_pm_name = canonical_pm_name;
							f_pm_sentinel_addr = !pm_sentinel_addr;
							f_codegen_type = !codegen_type;
							f_pm_sentinel_addr_loc = 0;
						} in
	

						if !codegen_type = "indirect" then begin
							let slt_indirect_xfer_table_entry : Defs.Basedefs.slt_indirect_xfer_table_info_t = {
								f_canonical_pm_name = canonical_pm_name;
								f_sentinel_type = sentinel_type;
								f_table_offset = !slt_indirect_xfer_table_offset;
								f_addr = !pm_sentinel_addr;
							} in

							callees_slt_indirect_xfer_table_assoc_list := !callees_slt_indirect_xfer_table_assoc_list @
								[ (canonical_pm_name_with_sentinel_suffix, slt_indirect_xfer_table_entry) ];

							slt_codegen_info.f_pm_sentinel_addr_loc <- !slt_indirect_xfer_table_offset;

							slt_indirect_xfer_table_offset := !slt_indirect_xfer_table_offset + d_mf_json_node_uberspark_uobjslt_var.f_addr_size;
						end;

						callees_slt_codegen_info_list := !callees_slt_codegen_info_list @ [ slt_codegen_info ];

						Uberspark_logger.log ~lvl:Uberspark_logger.Debug "added entry: name=%s, addr=0x%08x" 
							slt_codegen_info.f_canonical_pm_name slt_codegen_info.f_pm_sentinel_addr;
					end;

				) callees_sentinel_type_list;
				
			) pm_name_list;
		) callees_hashtbl;

		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "prepare_slt_codegen: end";

		()
	;




	(*--------------------------------------------------------------------------*)
	(* prepare uobj sources *)
	(*--------------------------------------------------------------------------*)
	method prepare_sources
		()
		: unit =

		(* copy all the uobj c files to build area *)
		if (List.length json_node_uberspark_uobj_var.f_sources.f_c_files) > 0 then begin
			Uberspark_osservices.cp (self#get_d_path_to_mf_filename ^ "/*.c") (self#get_d_builddir ^ "/.");
		end;

		(* copy all the uobj h files to build area *)
		if (List.length json_node_uberspark_uobj_var.f_sources.f_h_files) > 0 then begin
			Uberspark_osservices.cp (self#get_d_path_to_mf_filename ^ "/*.h") (self#get_d_builddir ^ "/.");
		end;

		(* copy all the uobj cS files to build area *)
		if (List.length json_node_uberspark_uobj_var.f_sources.f_casm_files) > 0 then begin
			Uberspark_osservices.cp (self#get_d_path_to_mf_filename ^ "/*.cS") (self#get_d_builddir ^ "/.");
		end;

		(* generate uobj top-level include header file source *)
		Uberspark_logger.log ~crlf:false "Generating uobj top-level include header source...";
		Uberspark_codegen.Uobj.generate_top_level_include_header 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_top_level_include_header_src_filename)
			self#get_d_publicmethods_hashtbl;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* prepare slt codegen for intrauobjcoll, interuobjcoll and legacy callees *)
		self#prepare_slt_codegen d_intrauobjcoll_callees_slt_codegen_info_list 
			d_intrauobjcoll_callees_slt_indirect_xfer_table_assoc_list
			d_slt_info.f_intrauobjcoll_callees_sentinel_type_hashtbl  
			d_slt_info.f_intrauobjcoll_callees_sentinel_address_hashtbl
			self#get_d_intrauobjcoll_callees_hashtbl;

		(* generate slt for intra-uobjcoll callees *)
		let rval = (Uberspark_codegen.Uobj.generate_slt 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobjslt_intrauobjcoll_callees_src_filename)
			~output_banner:"uobj sentinel linkage table for intra-uobjcoll callees" 
			d_mf_json_node_uberspark_uobjslt_var.f_code_directxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_indirectxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_addrdef
			!d_intrauobjcoll_callees_slt_codegen_info_list
			".uobj_intrauobjcoll_csltcode"
			!d_intrauobjcoll_callees_slt_indirect_xfer_table_assoc_list
			".uobj_intrauobjcoll_csltdata") in	
		if (rval == false) then
			begin
				Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to generate slt for intrauobjcoll callees!";
				ignore (exit 1);
			end
		;

		(* generate slt for interuobjcoll callees *)
		let rval = (Uberspark_codegen.Uobj.generate_slt 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobjslt_interuobjcoll_callees_src_filename) 
			~output_banner:"uobj sentinel linkage table for inter-uobjcoll callees" 
			d_mf_json_node_uberspark_uobjslt_var.f_code_directxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_indirectxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_addrdef
			!d_interuobjcoll_callees_slt_codegen_info_list
			".uobj_interuobjcoll_csltcode"
			!d_interuobjcoll_callees_slt_indirect_xfer_table_assoc_list
			".uobj_interuobjcoll_csltdata") in	
		if (rval == false) then
			begin
				Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to generate slt for inter-uobjcoll callees!";
				ignore (exit 1);
			end
		;


		(* generate slt for legacy callees *)
		let rval = (Uberspark_codegen.Uobj.generate_slt 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobjslt_legacy_callees_src_filename) 
			~output_banner:"uobj sentinel linkage table for legacy callees" 
			d_mf_json_node_uberspark_uobjslt_var.f_code_directxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_indirectxfer
			d_mf_json_node_uberspark_uobjslt_var.f_code_addrdef
			!d_legacy_callees_slt_codegen_info_list
			".uobj_legacy_csltcode"
			!d_legacy_callees_slt_indirect_xfer_table_assoc_list
			".uobj_legacy_csltdata") in	
		if (rval == false) then
			begin
				Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to generate slt for legacy callees!";
				ignore (exit 1);
			end
		;

		(* generate uobj binary public methods info source *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary public methods info source...";
		Uberspark_codegen.Uobj.generate_src_publicmethods_info 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_publicmethods_info_src_filename)
			(json_node_uberspark_uobj_var).f_namespace d_publicmethods_hashtbl;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* generate uobj binary intrauobjcoll callees info source *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary intrauobjcoll callees info source...";
		Uberspark_codegen.Uobj.generate_src_intrauobjcoll_callees_info 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_intrauobjcoll_callees_info_src_filename)
			d_intrauobjcoll_callees_hashtbl;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* generate uobj binary interuobjcoll callees info source *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary interuobjcoll callees info source...";
		Uberspark_codegen.Uobj.generate_src_interuobjcoll_callees_info 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_interuobjcoll_callees_info_src_filename)
			d_interuobjcoll_callees_hashtbl;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* generate uobj binary legacy callees info source *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary legacy callees info source...";
		Uberspark_codegen.Uobj.generate_src_legacy_callees_info 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_legacy_callees_info_src_filename)
			self#get_d_legacy_callees_hashtbl;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* generate uobj binary header source *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary header source...";
		Uberspark_codegen.Uobj.generate_src_binhdr 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_binhdr_src_filename)
			(json_node_uberspark_uobj_var).f_namespace self#get_d_load_addr self#get_d_size 
			self#get_d_memorymapped_sections_list_val;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* generate uobj binary linker script *)
		Uberspark_logger.log ~crlf:false "Generating uobj binary linker script...";
		Uberspark_codegen.Uobj.generate_linker_script 
			(self#get_d_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_linkerscript_filename)
			self#get_d_load_addr self#get_d_size self#get_d_memorymapped_sections_list_val;
		Uberspark_logger.log ~tag:"" "[OK]";


		(* add all the autogenerated C source files to the list of c sources *)
		json_node_uberspark_uobj_var.f_sources.f_c_files <-  [ 
			Uberspark_namespace.namespace_uobj_publicmethods_info_src_filename;		
			Uberspark_namespace.namespace_uobj_intrauobjcoll_callees_info_src_filename;
			Uberspark_namespace.namespace_uobj_interuobjcoll_callees_info_src_filename;
			Uberspark_namespace.namespace_uobj_legacy_callees_info_src_filename;
			Uberspark_namespace.namespace_uobj_binhdr_src_filename;
		] @ json_node_uberspark_uobj_var.f_sources.f_c_files;


		(* add all the autogenerated asm source files to the list of asm sources *)
		(* TBD: eventually this will just be casm sources *)
		json_node_uberspark_uobj_var.f_sources.f_asm_files <- [ 
			Uberspark_namespace.namespace_uobjslt_intrauobjcoll_callees_src_filename;
			Uberspark_namespace.namespace_uobjslt_interuobjcoll_callees_src_filename;
			Uberspark_namespace.namespace_uobjslt_legacy_callees_src_filename;
		] @ json_node_uberspark_uobj_var.f_sources.f_asm_files;

		()
	;




	(*--------------------------------------------------------------------------*)
	(* initialize *)
	(*--------------------------------------------------------------------------*)
	method initialize	
		?(builddir = ".")
		(uobj_mf_filename : string)
		(target_def: Defs.Basedefs.target_def_t)
		(uobj_load_address : int)
		: bool = 
	
		(* store uobj manifest filename *)
		self#set_d_mf_filename (Filename.basename uobj_mf_filename);

		(* set target definition *)
		self#set_d_target_def target_def;	

		(* set load address *)
		self#set_d_load_addr uobj_load_address;

		(* store absolute uobj path *)		
		let (rval, abs_uobj_path) = (Uberspark_osservices.abspath (Filename.dirname uobj_mf_filename)) in
		if(rval == false) then (false) (* could not obtain absolute path for uobj *)
		else
	
		let dummy = 0 in begin
		self#set_d_path_to_mf_filename abs_uobj_path;

		(* set build directory *)
		self#set_d_builddir (abs_uobj_path ^ "/" ^ builddir);

		(* debug dump the target spec and definition *)		
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "uobj target spec => %s:%s:%s" 
				(json_node_uberspark_uobj_var).f_platform (json_node_uberspark_uobj_var).f_arch (json_node_uberspark_uobj_var).f_cpu;
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "uobj target definition => %s:%s:%s" 
				(self#get_d_target_def).f_platform (self#get_d_target_def).f_arch (self#get_d_target_def).f_cpu;
		end;


		(* parse manifest *)
		let rval = (self#parse_manifest ()) in	
		if (rval == false) then	begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to stat/parse manifest for uobj!";
			(rval)
		end else

		let dummy = 0 in begin
		Uberspark_logger.log "successfully parsed uobj manifest";
		end;

		(* parse uobj slt manifest *)
		let rval = (self#parse_manifest_slt) in	
		if (rval == false) then	begin
				Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to stat/parse uobj slt manifest!";
				(rval)
		end else

		let dummy=0 in begin
		(* add default uobj sections *)
		self#add_default_uobj_binary_sections ();

		(* consolidate uboj section memory map *)
		Uberspark_logger.log "Consolidating uobj section memory map...";
		self#consolidate_sections_with_memory_map ();
		Uberspark_logger.log "uobj section memory map initialized";

		(* create _build folder *)
		Uberspark_osservices.mkdir ~parent:true (self#get_d_builddir) (`Octal 0o0777);
		end;

		(true)	
	;


	(*--------------------------------------------------------------------------*)
	(* compile c files *)
	(*--------------------------------------------------------------------------*)
	method compile_c_files	
		()
		: bool = 
		
		let retval = ref false in

		retval := Uberspark_bridge.Cc.invoke ~gen_obj:true
			 ~context_path_builddir:Uberspark_namespace.namespace_uobj_build_dir 
			 (json_node_uberspark_uobj_var.f_sources.f_c_files) [ "."; (Uberspark_namespace.get_namespace_staging_dir_prefix ()) ] ".";

		(!retval)	
	;


	(*--------------------------------------------------------------------------*)
	(* compile asm files *)
	(*--------------------------------------------------------------------------*)
	method compile_asm_files	
		()
		: bool = 
		
		let retval = ref false in

		retval := Uberspark_bridge.As.invoke ~gen_obj:true
			 ~context_path_builddir:Uberspark_namespace.namespace_uobj_build_dir 
			 (json_node_uberspark_uobj_var.f_sources.f_asm_files) [ "."; (Uberspark_namespace.get_namespace_staging_dir_prefix ()) ] ".";

		(!retval)	
	;



	(*--------------------------------------------------------------------------*)
	(* link uobj object files into binary image *)
	(*--------------------------------------------------------------------------*)
	method link_object_files	
		()
		: bool = 
		
		let retval = ref false in
		let o_file_list =ref [] in

		(* add object files generated from c sources *)
		List.iter (fun fname ->
			o_file_list := !o_file_list @ [ fname ^ ".o"];
		) json_node_uberspark_uobj_var.f_sources.f_c_files;

		(* add object files generated from asm sources *)
		List.iter (fun fname ->
			o_file_list := !o_file_list @ [ fname ^ ".o"];
		) json_node_uberspark_uobj_var.f_sources.f_asm_files;


		retval := Uberspark_bridge.Ld.invoke 
			 ~context_path_builddir:Uberspark_namespace.namespace_uobj_build_dir 
			Uberspark_namespace.namespace_uobj_linkerscript_filename
			Uberspark_namespace.namespace_uobj_binary_image_filename
			!o_file_list
			[ ] [ ]	".";

		(!retval)	
	;



	method install_create_ns 
		()
		: unit =
		
		let uobj_path_ns = self#get_d_path_ns in
		
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "d_path_ns=%s" uobj_path_ns;
		
		(* make namespace folder if not already existing *)
		Uberspark_osservices.mkdir ~parent:true uobj_path_ns (`Octal 0o0777);

		(* make namespace include folder if not already existing *)
		Uberspark_osservices.mkdir ~parent:true (uobj_path_ns ^ "/include") (`Octal 0o0777);

	;


	method install_h_files_ns 
		?(context_path_builddir = ".")
		: unit =
		
		let uobj_path_to_mf_filename = self#get_d_path_to_mf_filename in
		let uobj_path_ns = self#get_d_path_ns in
		
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "d_path_to_mf_filename=%s" uobj_path_to_mf_filename;
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "d_path_ns=%s" uobj_path_ns;
		


		(* copy h files to namespace *)
		List.iter ( fun h_filename -> 
			Uberspark_osservices.file_copy (uobj_path_to_mf_filename ^ "/" ^ h_filename)
			(uobj_path_ns ^ "/include/" ^ h_filename);
		) json_node_uberspark_uobj_var.f_sources.f_h_files;

		(* copy top-level header to namespace *)
		Uberspark_osservices.file_copy (uobj_path_to_mf_filename ^ "/" ^ context_path_builddir ^ "/" ^ Uberspark_namespace.namespace_uobj_top_level_include_header_src_filename)
			(uobj_path_ns ^ "/include/" ^ Uberspark_namespace.namespace_uobj_top_level_include_header_src_filename);

	;


	method remove_ns 
		()
		: unit =
		
		let uobj_path_ns = self#get_d_path_ns in
		
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "d_path_ns=%s" uobj_path_ns;
		
		(* remove the path and files within *)
		Uberspark_osservices.rmdir_recurse [ uobj_path_ns ];
	;


	(* assumes initialize method has been called *)
	method prepare_namespace_for_build
		()
		: bool =

		let retval = ref false in
		let in_namespace_build = ref false in

		(* check to see if we are doing an in-namespace build or an out-of-namespace build *)
		let dummy = 0 in begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "namespace root=%s" ((Uberspark_namespace.get_namespace_staging_dir_prefix ()) ^ "/" ^ Uberspark_namespace.namespace_root ^ "/");
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "abs_uobj_path_ns=%s" (self#get_d_path_to_mf_filename);
		
		in_namespace_build := (Uberspark_namespace.is_uobj_uobjcoll_abspath_in_namespace self#get_d_path_to_mf_filename);
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "in_namespace_build=%B" !in_namespace_build;

		(* install headers if we are doing an out-of-namespace build *)
		if not !in_namespace_build then begin
			Uberspark_logger.log "prepping for out-of-namespace build...";
			self#install_create_ns ();
			self#install_h_files_ns ~context_path_builddir:Uberspark_namespace.namespace_uobj_build_dir;
			Uberspark_logger.log "ready for out-of-namespace build";
		end;

		retval := true;
		end;


		(!retval)
	;



	(* build the uobj binary image *)
	method build_image
		()
		: bool =

		let retval = ref false in

		(* switch working directory to uobj_path build folder *)
		let (rval, r_prevpath, r_curpath) = (Uberspark_osservices.dir_change (self#get_d_builddir)) in
		if(rval == false) then begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not switch to uobj path: %s" self#get_d_builddir;
			(!retval)
		end else

		(* initialize bridges *)
		(*if not (Uberspark_bridge.initialize_from_config ()) then begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not initialize bridges!";
			(!retval)
		end else
		*)

		let dummy =0 in begin
	    (*Uberspark_logger.log "initialized bridges";*)
	   	Uberspark_logger.log "proceeding to compile c files...";
		end;

		if not (self#compile_c_files ()) then begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not compile one or more uobj c files!";
			(!retval)
		end else

		let dummy = 0 in begin
		Uberspark_logger.log "compiled c files successfully!";
		Uberspark_logger.log "proceeding to compile asm files...";
		end;

		if not (self#compile_asm_files ()) then begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not compile one or more uobj asm files!";
			(!retval)
		end else

		let dummy = 0 in begin
		Uberspark_logger.log "compiled asm files successfully!";
		Uberspark_logger.log "proceeding to link object files...";
		end;

		if not (self#link_object_files ()) then begin
			Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not link uobj object files!";
			(!retval)
		end else


		let dummy = 0 in begin
		Uberspark_logger.log "linked object files successfully!";

		(* restore working directory *)
		ignore(Uberspark_osservices.dir_change r_prevpath);

		Uberspark_logger.log "cleaned up build";
		retval := true;
		end;

		(!retval)
	;
	

end;;




(*
let build
	(uobj_path : string)
	(uobj_target_def : Defs.Basedefs.target_def_t)
	: bool =

	let retval = ref false in
	let in_namespace_build = ref false in

	let (rval, abs_uobj_path) = (Uberspark_osservices.abspath uobj_path) in
	if(rval == false) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not obtain absolute path for uobj: %s" abs_uobj_path;
		(!retval)
	end else

	(* switch working directory to uobj_path *)
	let (rval, r_prevpath, r_curpath) = (Uberspark_osservices.dir_change abs_uobj_path) in
	if(rval == false) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not switch to uobj path: %s" abs_uobj_path;
		(!retval)
	end else

	let dummy = 0 in begin

	(* create _build folder *)
	Uberspark_osservices.mkdir ~parent:true Uberspark_namespace.namespace_uobj_build_dir (`Octal 0o0777);

	end;

	if not (Uberspark_bridge.initialize_from_config ()) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not initialize bridges!";
		(!retval)
	end else
	

	let uobj_mf_filename = (abs_uobj_path ^ "/" ^ Uberspark_namespace.namespace_uobj_mf_filename) in
	let dummy = 0 in begin
    Uberspark_logger.log "initialized bridges";
	Uberspark_logger.log "parsing uobj manifest: %s" uobj_mf_filename;
	end;

    (* create uobj instance and parse manifest *)
	let uobj = new uobject in
	let rval = (uobj#parse_manifest ()) in	
    if (rval == false) then	begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to stat/parse manifest for uobj: %s" uobj_mf_filename;
		(!retval)
	end else

	let dummy = 0 in begin

	Uberspark_logger.log "successfully parsed uobj manifest";
	(*TBD: validate platform, arch, cpu target def with uobj target spec*)

	(* initialize uobj initial state *)
	(* TBD: we need to get the load address as argument to the build interface *)
	uobj#initialize ~context_path_builddir:Uberspark_namespace.namespace_uobj_build_dir uobj_target_def 
		Uberspark_config.json_node_uberspark_config_var.uobj_binary_image_load_address;

	if (List.length uobj#get_json_node_uberspark_uobj_var.f_sources.f_c_files) > 0 then begin
		Uberspark_osservices.cp "*.c" (Uberspark_namespace.namespace_uobj_build_dir ^ "/.");
	end;

	if (List.length uobj#get_json_node_uberspark_uobj_var.f_sources.f_h_files) > 0 then begin
		Uberspark_osservices.cp "*.h" "./_build/.";
	end;

	if (List.length uobj#get_json_node_uberspark_uobj_var.f_sources.f_casm_files) > 0 then begin
		Uberspark_osservices.cp "*.cS" "./_build/.";
	end;


    Uberspark_logger.log "proceeding to compile c files...";
	end;

	if not (uobj#compile_c_files ()) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not compile one or more uobj c files!";
		(!retval)
	end else

	let dummy = 0 in begin
	Uberspark_logger.log "compiled c files successfully!";
    Uberspark_logger.log "proceeding to compile asm files...";
	end;

	if not (uobj#compile_asm_files ()) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not compile one or more uobj asm files!";
		(!retval)
	end else

	let dummy = 0 in begin
	Uberspark_logger.log "compiled asm files successfully!";
    Uberspark_logger.log "proceeding to link object files...";
	end;

	if not (uobj#link_object_files ()) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not link uobj object files!";
		(!retval)
	end else


	let dummy = 0 in begin
	Uberspark_logger.log "linked object files successfully!";

	(* cleanup namespace if we are doing an out-of-namespace build *)
	(*if not !in_namespace_build then begin
		uobj#remove_ns ();
	end;*)

	(* restore working directory *)
	ignore(Uberspark_osservices.dir_change r_prevpath);

	Uberspark_logger.log "cleaned up build";
	retval := true;
	end;

	(!retval)
;;
*)

	
let create_initialize_and_build
	(uobj_mf_filename : string)
	(uobj_target_def : Defs.Basedefs.target_def_t)
	(uobj_load_address : int)
	: bool * uobject option =

	(* create uobj instance and initialize *)
	let uobj = new uobject in
	let rval = (uobj#initialize ~builddir:Uberspark_namespace.namespace_uobj_build_dir 
		uobj_mf_filename uobj_target_def uobj_load_address) in	
    if (rval == false) then	begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to initialize uobj!";
		(false, None)
	end else

	(* prepare uobj sources *)
	let dummy = 0 in begin
	Uberspark_logger.log "initialized uobj";
	uobj#prepare_sources ();
	Uberspark_logger.log "prepped uobj sources";
	end;

	(* prepare uobj namespace *)
	let rval = (uobj#prepare_namespace_for_build ()) in	
    if (rval == false) then	begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to prepare uobj namespace!";
		(false, None)
	end else

	let dummy = 0 in begin
	Uberspark_logger.log "prepped uobj namespace";
	end;

	(* initialize bridges *)
	let l_rval = ref true in 
	let dummy = 0 in begin

	(* if uobj manifest specified config-settings node, re-initialize bridges to be sure 
	 we get uobj specific bridges if specified *)
	if (uobj#overlay_config_settings ()) then begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "initializing bridges with uobj manifest override...";
		if not (Uberspark_bridge.initialize_from_config ()) then begin
			l_rval := false;
		end;
	end else begin
		(* uobj manifest did not have any config-settings specified *)
		Uberspark_logger.log ~lvl:Uberspark_logger.Debug "initializing bridges with default config settings...";
		if not (Uberspark_bridge.initialize_from_config ()) then begin
			l_rval := false;
		end;
	end;
	end;

    if (!l_rval == false) then	begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "could not initialize bridges!";
		(false, None)
	end else

	(* build uobj binary image *)
	let rval = (uobj#build_image ()) in	
    if (rval == false) then	begin
		Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to build uobj binary image!";
		(false, None)
	end else

	let dummy = 0 in begin
	Uberspark_logger.log "generated uobj binary image";
	end;

	(true, Some uobj)
;;


(*--------------------------------------------------------------------------*)
(* FOR FUTURE EXPANSION *)
(*--------------------------------------------------------------------------*)

(*

	(* get uobj manifest json nodes *)
	let rval = (Uberspark_manifest.Uobj.get_uobj_mf_json_nodes mf_json d_uobj_mf_json_nodes) in

	if (rval == false) then (false)
	else

	(* debug *)
	(*let dummy = 0 in begin
	Uberspark_logger.log ~lvl:Uberspark_logger.Debug "mf_json=%s" (Uberspark_manifest.json_node_pretty_print_to_string mf_json);
	let (rval, new_json) = Uberspark_manifest.json_node_update "namespace" (Yojson.Basic.from_string "\"uberspark/uobjs/wohoo\"") (Yojson.Basic.Util.member "uobj-hdr" mf_json) in
	Uberspark_logger.log ~lvl:Uberspark_logger.Debug "mf_json=%s" (Uberspark_manifest.json_node_pretty_print_to_string new_json);
	d_uobj_mf_json_nodes.f_uobj_hdr <- new_json;
	self#write_manifest "auto_test.json";		
	end;*)



	val d_uobj_mf_json_nodes : Uberspark_manifest.Uobj.uobj_mf_json_nodes_t = {
		f_uberspark_hdr = `Null;
		f_uobj_hdr = `Null;
		f_uobj_sources = `Null;
		f_uobj_publicmethods = `Null;
		f_uobj_intrauobjcoll_callees = `Null;
		f_uobj_interuobjcoll_callees = `Null;
		f_uobj_legacy_callees = `Null;
		f_uobj_binary = `Null;
	};


	(*--------------------------------------------------------------------------*)
	(* write uobj manifest *)
	(* uobj_mf_filename = uobj manifest filename *)
	(*--------------------------------------------------------------------------*)
	method write_manifest 
		(uobj_mf_filename : string)
		: bool =

		let oc = open_out uobj_mf_filename in
		Uberspark_manifest.Uobj.write_uobj_mf_json_nodes d_uobj_mf_json_nodes oc;
		close_out oc;	

		(true)
	;
*)