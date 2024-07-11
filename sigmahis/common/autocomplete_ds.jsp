<%
String dsType = request.getParameter("dsType");
String dsMatchBy = request.getParameter("dsMatchBy");
String dsRecordDelim = request.getParameter("dsRecordDelim");
String dsFieldDelim = request.getParameter("dsFieldDelim");
String query = request.getParameter("query");
String int_items = request.getParameter("int_items");
if (dsType == null) dsType = "";
if (dsMatchBy == null) dsMatchBy = "description";
if (dsRecordDelim == null) dsRecordDelim = "\n";
if (dsFieldDelim == null) dsFieldDelim = "\t";
if (query == null) query = "";
if (int_items == null) int_items = "";
String cds = request.getParameter("cds");
String soloBm = request.getParameter("soloBm");
String valDispOmFar = request.getParameter("validar_disp_om_far");
String valDispOmBm = request.getParameter("validar_disp_om_bm");
if (cds == null || cds.trim().equals("")) cds = "";
if (soloBm == null) soloBm = "";
if (valDispOmFar == null) valDispOmFar = "";
if (valDispOmBm == null) valDispOmBm = "";

//System.out.println("/ / / / / / / / / /dsType = "+dsType+" dsMatchBy = "+dsMatchBy+" dsRecordDelim = "+dsRecordDelim+" dsFieldDelim = "+dsFieldDelim+" query = "+query);
if(request.getMethod().equalsIgnoreCase("GET")) {
	issi.admin.SQLMgr SQLMgr = new issi.admin.SQLMgr((issi.admin.ConnectionMgr) session.getAttribute("ConMgr"));
	java.util.ArrayList al = new java.util.ArrayList();
	StringBuffer sbSql = new StringBuffer();

	if (dsType.equalsIgnoreCase("drug")) {

		//parameters defined in dsQueryString
		
		if (cds == null || cds.trim().equals("")) cds = "127";

		sbSql.append("select codigo as id, upper(descripcion) as description, nvl(cpt,' ') as refer from tbl_cds_producto_x_cds where estatus = 'A' and cod_centro_servicio = ");
		sbSql.append(cds);
		/*if (!query.trim().equals("")) {
			sbSql.append(" and upper(descripcion) like '%");
			sbSql.append(query.toUpperCase());
			sbSql.append("%'");
		}*/
		sbSql.append(" order by ");
		sbSql.append(dsMatchBy);

	} else if (dsType.equalsIgnoreCase("MED")) {

		StringBuffer sbOrderBy = new StringBuffer();
		sbOrderBy.append(dsMatchBy);
		String compania = request.getParameter("compania");
		String companiaFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");
		if (companiaFar == null || companiaFar.trim().equals("")) companiaFar = "1";
		if (compania == null || compania.trim().equals("")) compania = "1";
		//System.out.println("CDS =="+cds);
		boolean intItems = false;
		if ((int_items.equalsIgnoreCase("Y") || int_items.equalsIgnoreCase("S"))) intItems = true;

		boolean valDispFar = valDispOmFar.equalsIgnoreCase("S") || valDispOmFar.equalsIgnoreCase("Y");
		boolean valDispBm = valDispOmBm.equalsIgnoreCase("S") || valDispOmBm.equalsIgnoreCase("Y");
	
		sbSql = new StringBuffer();
		sbSql.append("select distinct bm.cod_articulo as id, upper(a.descripcion) as description, bm.compania as refer, '");
		if (intItems) sbSql.append("* BANCO");
		else sbSql.append(" ");
		sbSql.append("' as xtra1, 1 as xtra2 ");
		if (soloBm.equalsIgnoreCase("S"))
		{
			sbSql.append(", ( select distinct a.almacen from tbl_sec_cds_almacen a,tbl_inv_almacen b,tbl_inv_inventario i where a.almacen=b.codigo_almacen and b.compania=");
			sbSql.append(compania);
			sbSql.append(" and a.cds = ");
			sbSql.append(cds);
	
			sbSql.append(" and is_bm = 'Y' and i.estado = 'A' and a.almacen=i.codigo_almacen and i.cod_articulo= bm.cod_articulo and b.compania=i.compania and rownum =1  ) ");
		}else sbSql.append(", null  ");
		
		sbSql.append(" as xtra3 ");
		
		sbSql.append(" from tbl_inv_articulo a, tbl_inv_articulo_bm bm where bm.compania = a.compania and bm.cod_articulo = a.cod_articulo and a.compania = ");
		sbSql.append(compania);
		sbSql.append(" and a.estado = 'A' and bm.estado = 'A'");
		
		if (soloBm.equalsIgnoreCase("S"))
		{
			sbSql.append(" and exists ( select null from tbl_sec_cds_almacen a,tbl_inv_almacen b,tbl_inv_inventario i where a.almacen=b.codigo_almacen and b.compania=");
			sbSql.append(compania);
			sbSql.append(" and a.cds = ");
			sbSql.append(cds);
			if (valDispBm) {
				sbSql.append(" and nvl(i.disponible, 0) > 0 ");
			}
			sbSql.append(" and is_bm = 'Y' and i.estado = 'A' and a.almacen=i.codigo_almacen and i.cod_articulo= bm.cod_articulo and b.compania=i.compania ) ");
		}
		
		if (intItems) {
			sbSql.append(" union all ");
			sbSql.append("select distinct cod_articulo as id, upper(descripcion) as description, compania as refer, '*** FARMACIA' as xtra1, 2 as xtra2 ,null as xtra3 from tbl_inv_articulo where estado = 'A' and venta_sino ='S' and compania = ");
			sbSql.append(companiaFar);
			if (companiaFar.equals(compania))sbSql.append(" and replicado_far = 'S' ");
			
			if (valDispFar) {
				sbSql.append(" and cod_articulo in ( select cod_articulo from tbl_sec_cds_almacen a,tbl_inv_almacen b,tbl_inv_inventario i where a.almacen=b.codigo_almacen and b.compania = ");
				sbSql.append(companiaFar);
				sbSql.append(" and a.cds = ");
				sbSql.append(cds);
				sbSql.append(" and i.estado = 'A' and a.almacen = i.codigo_almacen and i.cod_articulo = cod_articulo and b.compania=i.compania and i.disponible > 0 ) ");
			}

			sbOrderBy.append(", xtra2");
		}
		sbSql.append(" order by ");
		sbSql.append(sbOrderBy);

	}	else if (dsType.equalsIgnoreCase("CEDLIST_PAC")) {

		sbSql.append("select distinct pac_id id,id_paciente description,nombre_paciente as refer from vw_adm_paciente ");           
		sbSql.append(" order by ");
		sbSql.append(dsMatchBy);

	}	else if (dsType.equalsIgnoreCase("EMPL_POS")) {

		sbSql.append("select 'EMPL' refer_to, compania, to_char (emp_id) as id, primer_nombre || ' ' || segundo_nombre || ' ' || primer_apellido || ' ' || segundo_apellido || decode (sexo, 'F', ' ' || apellido_casada) as description, null fecha_nac, null fecha_vencim, 0 limite, 0 aprobacion_hna, provincia || '-' || sigla || '-' || tomo || '-' || asiento xtra1, to_char (digito_verificador) xtra2, num_empleado as refer, nvl (b.id_precio, 0) xtra3, get_sec_comp_param(-1, 'TP_CLIENTE_EMP') xtra4 from tbl_pla_empleado a, tbl_clt_lista_precio b where estado <> 3 and 'EMPL' = b.tipo_clte(+) and a.emp_id = b.id_clte(+) and b.ref_id(+) = get_sec_comp_param(-1, 'TP_CLIENTE_EMP')");
		sbSql.append(" order by ");
		sbSql.append(dsMatchBy);

	} else if (dsType.equalsIgnoreCase("TRANSLATE")) {

		sbSql.append("select spa_descrip id,eng_descrip description from tbl_micro_translate where spa_descrip like '");  
		sbSql.append(query);
		sbSql.append("%' order by ");
		sbSql.append(dsMatchBy);
		//System.err.println("autocomplete     "+sbSql.toString());

	}


	

	if (sbSql.length() > 0) {
		al = SQLMgr.getDataList(sbSql.toString());
		java.util.ArrayList<String> fields = new java.util.ArrayList();
		if (al.size() > 0) {
			fields = java.util.Collections.list(((java.util.Enumeration)((issi.admin.CommonDataObject) al.get(0)).getColValues().propertyNames()));
			//for(int i=0;i<fields.size();i++)System.out.println("* "+fields.get(i));
		}
		for (int i = 0; i<al.size(); i++) {
			if (fields.contains(dsMatchBy)) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue(dsMatchBy));
			} else {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("description"));
			}
			out.print(dsFieldDelim);
			out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("id"));
			out.print(dsFieldDelim);
			out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("description"));
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("refer") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("refer"));
			}
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra1") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra1"));
			}
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra2") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra2"));
			}
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra3") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra3"));
			}
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra4") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra4"));
			}
			out.print(dsFieldDelim);
			if (((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra5") != null) {
				out.print(((issi.admin.CommonDataObject) al.get(i)).getColValue("xtra5"));
			}
			if ((i + 1) != al.size()) out.print(dsRecordDelim);
		}
	}
}
%>