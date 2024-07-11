<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String almacen = request.getParameter("almacen");
String tipo_pos = request.getParameter("tipo_pos");
String artType = request.getParameter("artType");
String doc_id = request.getParameter("doc_id");
String itbm = "0";
String __tp_cod_ ="N";
if(session.getAttribute("_taxPercent")==null || session.getAttribute("_taxPercent").toString().trim().equals("")) itbm = "0";
else itbm = (String) session.getAttribute("_taxPercent");
if(almacen==null) almacen = (request.getParameter("search") == null)?"2":"";
if(fp==null) fp = "";
if(artType==null) artType = "I";
if(doc_id==null) doc_id = "";
if(tipo_pos==null) tipo_pos = "";

String familia = "", clase = "", articulo = "", descripcion = "", consignacion = "", es_menu_dia = "", tipo = "", codigo = "",barCode="",familiaClase="";

if (request.getMethod().equalsIgnoreCase("GET")){
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

		CommonDataObject cdoP = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'POS_USE_KEYPAD'),'N') use_keypad from dual ");
		if (cdoP == null) {
			cdoP = new CommonDataObject();
			cdoP.addColValue("use_keypad","N");
		}
		boolean useKeypad = cdoP.getColValue("use_keypad").equalsIgnoreCase("S") || cdoP.getColValue("use_keypad").equalsIgnoreCase("Y");

	int recsPerPage = 50;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null){
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (request.getParameter("familia") != null) familia = request.getParameter("familia");
	if (request.getParameter("familiaClase") != null) familiaClase = request.getParameter("familiaClase");
	if (request.getParameter("art_clase") != null) clase = request.getParameter("art_clase");
	if (request.getParameter("cod_articulo") != null) articulo = request.getParameter("cod_articulo");
	if (request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if (request.getParameter("consignacion") != null) consignacion = request.getParameter("consignacion");
	if (request.getParameter("es_menu_dia") != null) es_menu_dia = request.getParameter("es_menu_dia");
	if (request.getParameter("tipo") != null) tipo = request.getParameter("tipo");
	if (request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if(tipo_pos.equals("CAF") && es_menu_dia.equals("")) es_menu_dia="Y";

	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'COD_FLIA_MEDIC'),'0') as drugFamily, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SHOW_DESC_TEC'),'N') as showTechDesc, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CANT_ART_POS'),'0') as defaultQty, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CHECK_DISP'),'S') as checkAvailability from dual");
	CommonDataObject param = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	if(artType.equals("I") || artType.equals("A")){
		sbSql.append("select 'I' tipo_articulo, a.cod_articulo id, a.cod_articulo, (case when ");
		sbSql.append(param.getColValue("drugFamily"));
		sbSql.append(" = d.cod_flia and '");
		sbSql.append(param.getColValue("showTechDesc"));
		sbSql.append("' = 'S' then (case when d.tech_descripcion is null then d.descripcion else d.tech_descripcion || '-' || d.descripcion end) else d.descripcion end) descripcion, d.precio_venta precio, d.precio_venta precio_ejecutivo, d.precio_venta precio_colaborador, d.precio_venta precio4, d.precio_venta precio5, d.precio_venta precio6, d.precio_venta precio7, d.precio_venta precio8, d.itbm, a.codigo_almacen, b.tipo_servicio, round((case when nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(", 'USA_ITBM_POS'), 'S') = 'S' then (decode(d.itbm, 'S', (case when d.other5 = 0 or d.other5 is null then ");
		sbSql.append(itbm);
		sbSql.append(" else d.other5 end), 0)/100) else 0 end), 2) gravable_perc, d.cod_flia, d.cod_clase, 'N' es_combo_adicional, ");
		sbSql.append(param.getColValue("defaultQty"));
		sbSql.append(" cantidad, 0 qty_ini, 0 total_desc, nvl(d.other3, 'N') afecta_inventario, round(nvl(a.precio, 0), 4) costo, nvl(a.disponible, 0) disponible, ");
		if (request.getParameter("search") != null) sbSql.append("(select descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen)||': '||");
		sbSql.append("nvl((select descripcion from tbl_inv_anaqueles_x_almacen aa where aa.compania = a.compania and aa.codigo_almacen = a.codigo_almacen and aa.codigo = a.codigo_anaquel), 'SIN UBICACION') anaquel, '");
		sbSql.append(param.getColValue("checkAvailability"));
		sbSql.append("' check_disp, d.cod_barra, 'N' combo_colaborador, b.item_decoration item_decoration, (select getValDesc(a.compania, a.cod_articulo, d.cod_flia) from dual) val_desc from tbl_inv_inventario a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c, tbl_inv_articulo d where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		if (!almacen.trim().equals("")) {
			sbSql.append(" and a.codigo_almacen in (");
			sbSql.append(almacen);
			sbSql.append(")");
		}
		else
		{
			if (!UserDet.getUserProfile().contains("0")) {
					sbSql.append(" and a.codigo_almacen in (");
					if (session.getAttribute("_almacen_cds") != null) sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
					else sbSql.append("-2");
					sbSql.append(")");
				}

		}
		sbSql.append(" and d.precio_venta > 0");
		if (articulo.trim().equals("")) {
			if(!familiaClase.equals("")){ sbSql.append(" and d.cod_clase = "); sbSql.append(familiaClase);}
			if (!familia.equals("")){sbSql.append(" and d.cod_flia in (");sbSql.append(familia);sbSql.append(")");}
			else {
				if(!UserDet.getUserProfile().contains("0")){
					sbSql.append(" and d.cod_flia in (");
						if(session.getAttribute("_familia")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_familia")));
						else sbSql.append("-2");
					sbSql.append(")");
				}
			}

		}
		if (!clase.equals("")){sbSql.append(" and d.cod_clase = ");sbSql.append(clase);}
		if (!articulo.equals("")){
			if(codigo.equals("B")) sbSql.append(" and d.cod_barra = '");
			else if(codigo.equals("C"))sbSql.append(" and to_char(a.cod_articulo) like '");
			if (crypt && request.getParameter("__tp_cod_") != null && request.getParameter("__tp_cod_").trim().equals("S")){
			try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("cod_articulo"),"_cUrl",256));}
			catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
			}
			else{ barCode = request.getParameter("cod_articulo");}

			sbSql.append(barCode);
			if(codigo.equals("B"))sbSql.append("'");
			else sbSql.append("%'");
			barCode ="";
		}
		if (!descripcion.equals("")){sbSql.append(" and upper(d.descripcion) like '%");sbSql.append(descripcion.toUpperCase());sbSql.append("%'");}
		//if (!cod_barra.equals("")){sbSql.append(" and upper(d.cod_barra) = '");sbSql.append(cod_barra);sbSql.append("'");}
		sbSql.append(" and a.compania = b.compania and b.tipo_servicio is not null and d.estado = 'A' and d.venta_sino = 'S' and a.compania = c.compania and a.compania = d.compania and d.cod_flia = b.cod_flia and d.cod_flia = c.cod_flia and d.cod_clase = c.cod_clase and d.cod_flia = b.cod_flia  and a.cod_articulo = d.cod_articulo ");
		if(artType.equals("A")) sbSql.append(" union ");
	}
	if(artType.equals("C") || artType.equals("A")){
		sbSql.append("select 'C' tipo_articulo, id, id cod_articulo, descripcion, precio1 precio, precio2 precio_ejecutivo, precio3 precio_colaborador, precio4, precio5, precio6, precio7, precio8, 'N' itbm, ");
		sbSql.append((almacen!=null && !almacen.equals("0") && !almacen.equals("")?almacen:"0"));
		sbSql.append(" codigo_almacen, nvl((select tipo_servicio from tbl_inv_familia_articulo fa where compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and fa.cod_flia = a.id_familia), ' ') tipo_servicio, 0 gravable_perc, 0 cod_flia, 0 cod_clase, a.es_combo_adicional, ");
		sbSql.append(param.getColValue("defaultQty"));
		sbSql.append(" cantidad, 0 qty_ini, 0 total_desc, 'N' afecta_inventario, round(getArtCosto(a.id, ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append("), 2) costo, 0 disponible, ' ' anaquel, 'N' check_disp, ' ' cod_barra, a.combo_colaborador, nvl(a.item_decoration, ( select item_decoration from tbl_inv_familia_articulo fa where compania = a.compania and fa.cod_flia = a.id_familia) ) item_decoration, (select getValDesc(a.compania, a.id, null) from dual) val_desc from tbl_caf_menu a where estado = 'A'");
		sbSql.append(" and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if (articulo.trim().equals("")) {

			if(!familia.equals("")){ sbSql.append(" and id_familia = "); sbSql.append(familia);}
			else {
				if(!UserDet.getUserProfile().contains("0")){
					sbSql.append(" and id_familia in (");
						if(session.getAttribute("_familia")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_familia")));
						else sbSql.append("-2");
					sbSql.append(")");
				}
			}

		}
		if (!articulo.equals("")){

			if(codigo.equals("B"))sbSql.append(" and a.codigo = '");
			else if(codigo.equals("C"))sbSql.append(" and to_char(a.id)  like '");
			if (crypt && request.getParameter("__tp_cod_") != null && request.getParameter("__tp_cod_").trim().equals("S")){
			try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("cod_articulo"),"_cUrl",256));}
			catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
			}
			else{ barCode = request.getParameter("cod_articulo");}

			sbSql.append(barCode);
			if(codigo.equals("B"))sbSql.append("'");
			else sbSql.append("%'");
			barCode ="";
		}
		if (!descripcion.equals("")){sbSql.append(" and upper(a.descripcion) like '%");sbSql.append(descripcion);sbSql.append("%'");}
		if (!es_menu_dia.equals("")){sbSql.append(" and es_menu_dia = '");sbSql.append(es_menu_dia);sbSql.append("'");}
		if (!tipo.equals("")){
					 sbSql.append(" and tipo like '%");
					 sbSql.append(tipo);
					 sbSql.append("%'");
				}
	}
	sbSql.append(" order by descripcion");
	if(artType.equals("F")){
		sbSql = new StringBuffer();
		sbSql.append("select other3 tipo_articulo, codigo id, codigo cod_articulo, descripcion, precio, precio precio_ejecutivo, precio precio_colaborador, precio precio4, precio precio5, precio precio6, precio precio7, precio precio8, nvl(gravable, 'N') itbm, round((nvl(gravable_perc, 0)/100), 2) gravable_perc, 0 familia, 0 clase, (cantidad+getQtyItems(doc_id, compania, codigo)) cantidad, cantidad qty_ini, id_descuento, almacen codigo_almacen, tipo_descuento, valor_descuento, total, total_desc, total_itbm, 'N' afecta_inventario, costo, tipo_servicio /*, doc_id, line_no, other1, other3, other4, other5*/, 'N' check_disp, ' ' cod_barra from tbl_fac_trxitems a where doc_id = ");sbSql.append(doc_id);
		if (!articulo.equals("")){sbSql.append(" and a.codigo like '");sbSql.append(articulo);sbSql.append("%'");}
		if (!descripcion.equals("")){sbSql.append(" and upper(a.descripcion) like '%");sbSql.append(descripcion);sbSql.append("%'");}
		//if (!es_menu_dia.equals("")){sbSql.append(" and es_menu_dia = '");sbSql.append(es_menu_dia);sbSql.append("'");}
		//if (!tipo.equals("")){sbSql.append(" and tipo = '");sbSql.append(tipo);sbSql.append("'");}
		sbSql.append(" order by line_no");
	}

	barCode = "";
	//if (!articulo.trim().equals("") || !descripcion.trim().equals("") || !doc_id.trim().equals("")) {
		StringBuffer sbAll = new StringBuffer();
		sbAll.append("select * from (select rownum as rn, a.* from (");
		sbAll.append(sbSql.toString());
		sbAll.append(") a) where rn between ");
		sbAll.append(previousVal);
		sbAll.append(" and ");
		sbAll.append(nextVal);
		al = SQLMgr.getDataList(sbAll.toString());

		sbAll = new StringBuffer();
		sbAll.append("select count(*) count FROM (");
		sbAll.append(sbSql.toString());
		sbAll.append(")");
		rowCount = CmnMgr.getCount(sbAll.toString());
	//}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";
	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

		String _selected1="", _selected2="", _selected3="", _selected4="";


		String[] _tipo = tipo.replaceAll("'","").split(",");

		for (int s=0;s<_tipo.length;s++){
			String cV = _tipo[s];
			if ("D".equals(cV)) _selected1 = " active";
			else if ("A".equals(cV)) _selected2 = " active";
			else if ("C".equals(cV)) _selected3 = " active";
			else if ("B".equals(cV)) _selected4 = " active";
			System.out.println("::::::::::::::::::::::::::::::::: "+_tipo[s]);
		}


%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.min.js"></script>

<script>
document.title = 'Inventario - '+document.title;
function addItem(i,tLinea){
	if(parent.document.form0.turno.value=='') {parent.document.form0.save.disabled=true;CBMSG.warning('Sr(a). Usuario, usted no tiene turno definido!'); return false;}
	if(tLinea==undefined) tLinea='I';
	var cia = '<%=(String) session.getAttribute("_companyId")%>';
	var almacen = eval('document.articles.codigo_almacen'+i).value;
	var flia = eval('document.articles.cod_flia'+i).value;
	var clase = eval('document.articles.cod_clase'+i).value;
	var codigo = eval('document.articles.cod_articulo'+i).value;
	var es_combo_adicional = eval('document.articles.es_combo_adicional'+i).value;
	var combo_colaborador = eval('document.articles.combo_colaborador'+i).value;
	var tipo_articulo = eval('document.articles.tipo_articulo'+i).value;
	var afecta_inventario = eval('document.articles.afecta_inventario'+i).value;
	var check_disp = eval('document.articles.check_disp'+i).value;
	var disp = 0, qty = 0;
	var refer_to = parent.document.form0.refer_to.value;
	var id_precio = parent.document.form0.id_precio.value;
	var precio_aplicado = parent.document.form0.precio_aplicado.value;
	var combo_adicional_aplicado = parent.document.form0.combo_adicional_aplicado.value;
	var tipo_factura = getRadioButtonValue(parent.document.form0.tipo_factura);
	var tipo_docto = parent.document.form0.tipo_docto.value;
	var usa_nivel_precio = parent.document.form0.usa_nivel_precio.value;
	var facturar_al_costo = parent.document.form0.facturar_al_costo.value;
	var p_ref_type = parent.document.form0.ref_id.value;
	var p_ref_id = parent.document.form0.client_id.value;
	var size = 0;
	var tipo_art = 'N', total_desc = 0, id_descuento = 0, tipo_descuento = '';
	var qty_art = 0;
	if(parent.document.form0.detSize) size=parent.document.form0.detSize.value;
	for(j=0;j<size;j++){
		if(codigo==eval('parent.document.form0.codigo'+j).value && (eval('parent.document.form0.tipo_descuento'+j).value=='' || eval('parent.document.form0.tipo_descuento'+j).value=='R')){
			qty+=parseInt(eval('parent.document.form0.cantidad'+j).value);
		}
		if(codigo!=eval('parent.document.form0.codigo'+j).value) qty_art++;
	}
	if((refer_to=='EMPL' || refer_to=='EMPO') && (size>0 && qty>=1 && qty_art!=0) && tipo_factura=='CR' && es_combo_adicional=='N' && '<%=tipo_pos%>' == 'CAF'){
		alert('No puede vender más de un artículo a crédito a un colaborador!');
	} else {
		qty = 0;
		if(tipo_articulo=='I' && (tipo_docto == 'FAC' || tipo_docto == 'NDB')){
			disp = getInvDisponible('<%=request.getContextPath()%>', cia, almacen, flia, clase, codigo);
			if(parent.document.form0.detSize){
				var size = parent.document.form0.detSize.value;
				for(j=0;j<size;j++){
					if(codigo==eval('parent.document.form0.codigo'+j).value && (eval('parent.document.form0.tipo_descuento'+j).value=='' || eval('parent.document.form0.tipo_descuento'+j).value=='R')){qty+=parseInt(eval('parent.document.form0.cantidad'+j).value);}
				}
			}
		}
		if(eval('document.articles.tipo_descuento'+i).value=='P' || eval('document.articles.tipo_descuento'+i).value=='M'){
			tipo_art = 'D'; total_desc = eval('document.articles.total_desc'+i).value; id_descuento =  eval('document.articles.id_descuento'+i).value;
			tipo_descuento =  eval('document.articles.tipo_descuento'+i).value;
			codigo += '@D@';
		}
		if(tipo_articulo!='I'  || check_disp == 'N' || (tipo_articulo=='I' && ((disp>0 && disp>=(qty+1)) || (disp>=0 && disp<(qty+1) && tipo_docto=='NCR'))) || (tipo_articulo=='I' && afecta_inventario =='N')){
			var spn = eval('document.articles.spn'+i).value+'&tipo_art='+tipo_art+'&total_desc='+total_desc+'&id_descuento='+id_descuento+'&artType=<%=artType%>&tipo_descuento='+tipo_descuento+'&id_precio='+id_precio;
			//alert("id_precio="+id_precio+", combo_colaborador="+combo_colaborador+", usa_nivel_precio="+usa_nivel_precio);
			if(id_precio!='0' && /*(precio_aplicado == 'N' || (es_combo_adicional == 'S' && combo_adicional_aplicado=='N') ||) combo_colaborador == 'N' &&*/ (usa_nivel_precio=='S')){
				var strprecio = 'Normal';
				if(id_precio == '1') strprecio = 'Normal';
				else if(id_precio == '2') strprecio = 'Ejecutivo';
				else if(id_precio == '3') strprecio = 'Colaborador';
				else strprecio = id_precio;
				if('<%=tipo_pos%>' == 'CAF'){
					var turno = parent.document.form0.turno.value;
					var qtyColItem = getDBData('<%=request.getContextPath()%>','getQtyColItems('+turno+', <%=(String) session.getAttribute("_companyId")%>, '+codigo+', '+p_ref_type+', \''+p_ref_id+'\')','dual','');
					//alert("qtyColItem="+qtyColItem);
					//if(confirm('Desea usar precio '+strprecio)){
						if(parseFloat(eval('document.articles.precio'+id_precio+'_'+i).value)>0.00){
							if(tipo_articulo=='C' && ((combo_colaborador == 'Y' && qtyColItem == '0' && chkArtPA(codigo)) || combo_colaborador == 'N')){
								spn = spn.replace('@precio@', eval('document.articles.precio'+id_precio+'_'+i).value)+'&codigo='+codigo+'@PA@&precio_app=S';
								parent.document.form0.precio_aplicado.value = 'S';
								if(eval('document.articles.cantidad'+i).value=0) spn = spn.replace('cantidad=0', 'cantidad=1');
								if(es_combo_adicional == 'S' && combo_adicional_aplicado=='N') parent.document.form0.combo_adicional_aplicado.value = 'S';
							} else spn = spn.replace('@precio@', eval('document.articles.precio1_'+i).value)+'&precio_app=N&codigo='+codigo;
						} else {alert('No puede aplicar precio igual a 0.00!');spn='';}
					//} else spn = spn.replace('@precio@', eval('document.articles.precio1_'+i).value)+'&codigo='+codigo;
				} else spn = spn.replace('@precio@', eval('document.articles.precio'+id_precio+'_'+i).value)+'&precio_app=N&codigo='+codigo;
			} else {spn = spn.replace('@precio@', (facturar_al_costo=='S'?eval('document.articles.costo'+i).value:eval('document.articles.precio1_'+i).value))+'&codigo='+codigo;}
			//alert(spn);
			if(spn!='' && chkQtyNC(i)){
			var txt = '';

			$.ajax({url:'../pos/detail.jsp?'+spn+'&adding=add&refer_to='+refer_to+'&timestamp='+Date.now()+'&show_desc=S'+'&use_keypad=<%=useKeypad%>&touch=Y',async:false,timeout:5000,success:function(txt){
					$('#left',parent.document).html(txt);
				}});
			//var txt=ajaxHandler('../pos/detail.jsp',spn+'&adding=add&refer_to='+refer_to,'GET');

			parent.calcTotal();
			}
			var addDesc2NC = parent.document.form0.addDesc2NC.value;
			var ret = '-1';
			if(tipo_docto=='NCR' && tLinea == 'I' && tipo_descuento=='' && addDesc2NC=='S') {
				ret = chkDesc(codigo);
				if(ret!='-1') addItem(ret, 'D');
			}
		} else alert('No hay disponibilidad de este artículo!');
	}
	parent.checkCredit();
}

function chkQtyNC(i){
	var addDesc2NC = parent.document.form0.addDesc2NC.value;
	var _artType = getRadioButtonValue(parent.window.frames['artFrame'].document.search01.artType);
	var reference_id = parent.document.form0.reference_id.value;
	var tipo_descuento = eval('document.articles.tipo_descuento'+i).value;
	var codigo = eval('document.articles.cod_articulo'+i).value;
	var tipo_articulo = eval('document.articles.tipo_articulo'+i).value;
	var size = 0;
	if(parent.document.form0.detSize) size = parent.document.form0.detSize.value;
	var qty_items = 0;
	console.log("size", size);
	if(reference_id != '') qty_items = parseInt(getDBData('<%=request.getContextPath()%>','getQtyItems('+reference_id+', <%=(String) session.getAttribute("_companyId")%>, '+codigo+')','dual',''));
	codigo = codigo.replace("-", "_");
	if(parent.document.form0.tipo_docto.value=='NCR' && (eval('parent.document.form0.xx_'+size+'_'+tipo_articulo+'a'+codigo) || (qty_items != 0)) && _artType=='F' && tipo_descuento ==''){
		var qty = parseInt(eval('document.articles.cantidad'+i).value);
		var _qty = 0;
		_qty = (eval('parent.document.form0.xx_'+size+'_'+tipo_articulo+'a'+codigo)?(parseInt(eval('parent.document.form0.xx_'+size+'_'+tipo_articulo+'a'+codigo).value)+1):qty);//;
		console.log("addDesc2NC", addDesc2NC);
		if(parseInt(eval('document.articles.qty_ini'+i).value) + qty_items - _qty < 0){
			alert('La cantidad no puede ser mayor a la registrada en la Factura!');
			return false;
		} else {/*eval('document.articles.cantidad'+i).value = ((qty_items-_qty)+qty);*/ return true;}
	} else return true;
}
function setArticles(obj){
	var doc_id = parent.document.form0.reference_id.value;
		var tipo=$('#tipo').val();
	var artType = getRadioButtonValue(obj, '');
	if(artType=='F' && doc_id == '') alert('Seleccione Factura!');
	else window.location = '../pos/sel_articles_cafeteria_touch.jsp?fp=fact_cafeteria&artType='+artType+'&doc_id='+doc_id+'&almacen=<%=almacen%>&familia=<%=familia%>&tipo_pos=<%=tipo_pos%>&tipo='+tipo;
}
function setArticle(val){
		var obj = document.search01.artType;
		setCheckedValue(obj, val);
		setArticles(obj);
}

function doAction(){
	//newHeight();
	var size = <%=al.size()%>;
	if(size==1 && '<%=codigo%>'=='B') addItem(0);
	document.search01.cod_articulo.focus();
}
function chkDesc(codigo){
	var size = document.articles.sizeDesc.value;
	var ret = '-1';
	for(i=0;i<size;i++){
		if(eval('document.articles._desc_cod_articulo'+i).value==codigo) ret = eval('document.articles._desc_id'+i).value;
	}
	return ret;
}

function chkArtPA(codigo){
	var size = 0;
	var valReturn = true;
	if(parent.document.form0.detSizePA) size = parent.document.form0.detSizePA.value;
	/*for (j=0;j<size;j++){
		//alert(eval('parent.document.form0.codigo_pa'+j).value);
		if(eval('parent.document.form0.codigo_pa'+j).value==codigo+'@PA@'){
			valReturn = false;
			break;
		}
	}*/
	if (size>0) valReturn = false;
	return valReturn;
}
</script>
<style>
.container { width: 100%;}
.copyright { margin-top: 50px; font-size: 12px; text-transform: uppercase; }
.copyright a { text-decoration: none; padding: 5px;background: #c0392b; color: #FFFFFF; }
.copyright a:hover { background: transparent; color: #c0392b; }

.button-container{
	display: table;
	float: left;
	padding: 5px;
	margin: 5px;
	text-transform: uppercase;
	overflow: hidden;
	height: 65px;
	width:65px;
}

.button {
	padding-right: 10px;
	padding-left: 10px;
	background-color:rgb(41,127,184);
	color:rgb(255,255,255);
	text-transform: uppercase;
	display:table-cell;
	vertical-align:middle;
	border-radius: 5px;
	text-shadow:0px 1px 0px rgba(0,0,0,0.5);
	box-shadow:0px 2px 2px rgba(0,0,0,0.2);
}

.button span {
	position: absolute;
	left: 0;
	width: 50px;
	background-color:rgba(0,0,0,0.5);
	border-top-left-radius: 5px;
	border-bottom-left-radius: 5px;
	border-right: 1px solid  rgba(0,0,0,0.15);
}

.button:hover span, .button.active span {
	background-color:rgb(0,102,26);
	border-right: 1px solid  rgba(0,0,0,0.3);
}

.button:active {
	margin-top: 2px;
	margin-bottom: 13px;
	box-shadow:0px 1px 0px rgba(255,255,255,0.5);
}

.button.grey {
	background: #575757;
}

.button.purple {
	background: #8e44ad;
}

.button.turquoise {
	background: #1abc9c;
}

.button.red {
	background: #e74c3c;
}
</style>
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search01"></jsp:param>
	<jsp:param name="barcodeEl" value="cod_articulo"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="descripcion,familia"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
<%if(useKeypad){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
		display:none;
		margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>
<%}%>
<script>
$(document).ready(function(){
	<%if(useKeypad){%>

		 $('#codigo').change(function(e){
			 var self = $(this);
			 if (self.val() && self.val() !== 'B') {
				 $('.art_keypad').keypad({keypadOnly: false});
				 $('.art_keypad').keypad('show');
			 } else $('.art_keypad').keypad('destroy');
		 });

			var opts ={
				keypadOnly: false,
				layout: [
				'1234567890-',
				'qwertyuiop' + $.keypad.CLOSE,
				'asdfghjkl' + $.keypad.CLEAR,
				'zxcvbnm' +
				$.keypad.SPACE_BAR + $.keypad.BACK]
		 };


			$('.__descripcion').keypad(opts);

			$(document).on('keyup',function(evt) {
				if (evt.keyCode == 27) {
					 $('.__descripcion, .art_keypad').keypad("hide");
				}
			});
	<%}%>

	$("#__tipo a.btn_red_link").click(function(e){
			e.stopImmediatePropagation();
			var $this = $(this);
			var cVal = $this.data("tipo");

			if (cVal){
				$('#tipo', window.parent.document).val(cVal);
				$("#tipo").val(cVal);
			 $("#search01").submit();
			}
	 });

	 /*$("#s_type_").click(function(e){
		e.preventDefault();
		var self = $(this);
		$("._type_").toggle();
		if ($("._type_").is(":visible")) $("#sign").text("-O");
		else $("#sign").text("+O");
	 });*/
});

function showFliaList(){
	if($("#dvClassFlia").css('display')=='none'){
		$("#dvClassFlia").show();
		$("#dvFliaClase").hide();
		$("#dvArticulo").hide();
	}else{
		$("#dvClassFlia").hide();
		$("#dvFliaClase").hide();
		$("#dvArticulo").hide();
	}
}
function showFliaClaseList(){
	if($("#dvFliaClase").css('display')=='none'){
		$("#dvFliaClase").show();
		$("#dvArticulo").show();
	}else{
		$("#dvFliaClase").hide();
		$("#dvArticulo").show();
	}
}

function setFlia(valor){
	document.search01.familia.value=valor;
	document.search01.familiaClase.value='';
	document.search01.submit();
}
function setFliaClase(valor){
	document.search01.familiaClase.value=valor;
	document.search01.submit();
}
</script>
<style>
body::-webkit-scrollbar {
		width: 1.5em;
}

body::-webkit-scrollbar-track {
		-webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
}

body::-webkit-scrollbar-thumb {
	background-color: darkgrey;
	outline: 1px solid slategrey;
}
.btn{
white-space:normal !important;
		max-width:60px;
	font-size: 10px;
}
.option-button {
		height: 60px;
	width: 60px;
	text-align: center;
}

</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();" style="margin-top:-10px">
<%if(!fp.equals("fact_cafeteria")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================	S E A R C H	  E N G I N E S	  S T A R T	  H E R E	================================ -->
		<table width="100%" cellpadding="0" cellspacing="0">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("fg",""+fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("tipo_pos",tipo_pos)%>
		<%=fb.hidden("__tp_cod_",__tp_cod_)%>

		<%=(request.getParameter("search") == null)?"":fb.hidden("search",request.getParameter("search"))%>
<% if (request.getParameter("search") == null) { %>
		<tr class="TextRow02 _type_">
			<td class="TextLabel">
						<%
						String cArtType1 = "",  cArtType2 = "",  cArtType3 = "", cArtType4 = "";
						if (artType.equals("I")) cArtType1 = " active";
						else if (artType.equals("C")) cArtType2 = " active";
						else if (artType.equals("A")) cArtType3 = " active";
						else if (artType.equals("F")) cArtType4 = " active";
						%>
				<!--Art&iacute;culos de:-->
				<%=fb.radio("artType","I",(artType.equals("I")),false,false,"","","onClick=\"javascript:setArticles(this);\"")%>
				<!--Inventario<a href="javascript:setArticle('I')" class="btn_red_link <%//=cArtType1%>">Inventario</a>-->
				<%=fb.radio("artType","C",(artType.equals("C")),false,false,"","","onClick=\"javascript:setArticles(this);\"")%>
				<!--Combos--><a href="javascript:setArticle('C')" class="btn btn-sm btn-danger <%=cArtType2%>">Combos</a>
				<%=fb.radio("artType","A",(artType.equals("A")),false,false,"","","onClick=\"javascript:setArticles(this);\"")%>
				<!--Ambos--><a href="javascript:setArticle('A')" class="btn btn-sm btn-danger <%=cArtType3%>">Ambos</a>
				<%=fb.radio("artType","F",(artType.equals("F")),false,false,"","","onClick=\"javascript:setArticles(this);\"")%>
				<!--Factura--><a href="javascript:setArticle('F')" class="btn btn-sm btn-danger <%=cArtType4%>">Factura</a>
								&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;
								<span class="_type_">
										<span id="__tipo">
												<%=fb.hidden("almacen",almacen)%>
												<%//=fb.hidden("familia",familia)%>
												<!--Tipo:&nbsp; -->
												<a href="#" class="btn btn-sm btn-warning <%=_selected1%>" data-tipo="D">Desayuno</a>
												<a href="#" class="btn btn-sm btn-warning <%=_selected2%>" data-tipo="A">Almuerzo</a>
												<a href="#" class="btn btn-sm btn-warning <%=_selected3%>" data-tipo="C">Cena</a>
										</span>
								</span>

			</td>
		</tr>
<% } else { %>
		<%=fb.hidden("artType",artType)%>

<% } %>&nbsp;<!--"D=Desayuno,A=Almuerzo,C=Cena,B=Almuerzo y Cena",
		<tr class="TextRow02 _type_">
			<td id="__tipo">
				<%//=fb.hidden("almacen",almacen)%>
								<%//=fb.hidden("familia",familia)%>
								Tipo:&nbsp;
								<a href="#" class="btn_red_link<%//=_selected1%>" data-tipo="D">Desayuno</a>
								<a href="#" class="btn_red_link<%//=_selected2%>" data-tipo="A">Almuerzo</a>
								<a href="#" class="btn_red_link<%//=_selected3%>" data-tipo="C">Cena</a>
						</td>
		</tr>-->
				<tr class="TextFilter" style="line-height:4; vertical-align:middle">
			<td width="15%">
				<% if(tipo_pos.equalsIgnoreCase("CAF")) { %>
				<!--Men&uacute; del d&iacute;a:-->
				<%//=fb.select("es_menu_dia","Y=Si,N=No",es_menu_dia,false,false,0,"Text10",null,null,null,"S")%>
				<!--Tipo:-->
				<%=fb.hidden("tipo",tipo)%>
				<% } %>
				<%=fb.hidden("codigo","B")%>
				<%//=fb.select("codigo","B=Cod. Barra,C=Cod. Articulo",codigo,false,false,0,"Text14",null,null)%>
				C&oacute;d.:
				<%=fb.textBox("cod_articulo",barCode,false,false,false,5,"__cod_articulo art_keypad ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
				Desc.:
				<%=fb.textBox("descripcion",descripcion,false,false,false,10,"Text14 ",null,null)%>
								<%=fb.hidden("familia",familia)%>
								<%=fb.hidden("familiaClase",familiaClase)%>
								<input type="button" class="btn btn-sm btn-success " id="selFamilia" name="selFamilia" value="FAMILIA" onClick="javascript:showFliaList();">
								<input type="button" class="btn btn-sm btn-warning " id="selFamiliaClase" name="selFamiliaClase" value="CLASE" onClick="javascript:showFliaClaseList();">

								<%//=fb.select(ConMgr.getConnection(),"select cod_flia, nombre from tbl_inv_familia_articulo where compania = "+(String) session.getAttribute("_companyId")+" order by 2","familia",familia,false,false,0,"","width:150px","onChange=\"javascript:document.search01.submit()\"","","T")%>&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="submit" class="btn btn-sm btn-primary" id="go" value="Ir">
				<!--&nbsp;&nbsp;&nbsp;&nbsp;<button type="button" class="CellbyteBtn pointer" id="s_type_">&nbsp;<span id="sign">+O</span>&nbsp;</button>-->
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		</table>
<!-- ================================	S E A R C H	  E N G I N E S	  E N D	  H E R E	================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("tipo_pos",tipo_pos)%>
			<%=fb.hidden("artType",artType)%>
			<%=fb.hidden("almacen",almacen)%>
			<%=fb.hidden("familia",familia)%>
			<%=fb.hidden("art_clase",clase)%>
			<%=fb.hidden("es_menu_dia",es_menu_dia)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("cod_articulo",articulo)%>
			<%=fb.hidden("descripcion",descripcion)%>
			<%=(request.getParameter("search") == null)?"":fb.hidden("search",request.getParameter("search"))%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
			<%=fb.formEnd()%>
			<td width="40%"><!--Total Registro(s) <%//=rowCount%>--></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
			<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("tipo_pos",tipo_pos)%>
			<%=fb.hidden("artType",artType)%>
			<%=fb.hidden("almacen",almacen)%>
			<%=fb.hidden("familia",familia)%>
			<%=fb.hidden("art_clase",clase)%>
			<%=fb.hidden("es_menu_dia",es_menu_dia)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("cod_articulo",articulo)%>
			<%=fb.hidden("descripcion",descripcion)%>
			<%=(request.getParameter("search") == null)?"":fb.hidden("search",request.getParameter("search"))%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("articles",request.getContextPath()+request.getServletPath(),FormBean.POST,"onSubmit=\"javascript:return(chkQty())\"");%>
<%=fb.formStart()%>
<!--
<tr>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("familia",familia)%>
	<%=fb.hidden("art_clase",clase)%>
	<%=fb.hidden("cod_articulo",articulo)%>
	<%=fb.hidden("descripcion",descripcion)%>
	<td align="left" class="TableLeftBorder">&nbsp;</td>
	<td align="right" class="TableRightBorder"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
</tr>
-->
<!-- Familia -->
<tr id="dvClassFlia" class="dvClassFlia" style="display:none">
	<td colspan="2" class="TableBottomBorder">
		<table width="100%" align="center">
			<tr class="TextHeader">
			<td align="center" class="">Familia</td></tr>
			<tr>
			<td>

			<%
			StringBuffer sbEvent = new StringBuffer();

			sbSql = new StringBuffer();
			sbSql.append("select cod_flia, nombre from tbl_inv_familia_articulo where compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and estado_pos = 'A' order by 2");
			ArrayList alFlia = new ArrayList();
			alFlia = SQLMgr.getDataList(sbSql.toString());
			%>
				<%
				for (int i=0; i<alFlia.size(); i++){
					CommonDataObject fdo = (CommonDataObject) alFlia.get(i);
					sbEvent = new StringBuffer();
					sbEvent.append(" onClick=\"javascript:setFlia(");
					sbEvent.append(fdo.getColValue("cod_flia"));
					sbEvent.append(")\" style=\"cursor:pointer\"");
				%>
			<div class="button-container pull-left">
					<div class="btn btn-xs btn-success option-button" <%=sbEvent%>>
						<%=(fdo.getColValue("nombre").length()>25) ? fdo.getColValue("nombre").substring(0,25):fdo.getColValue("nombre")%>
					</div>
			</div>
				<%}%>

</td>
</tr>

</table>
</td>
</tr>
<!-- Familia end -->
<% if (!familia.trim().equals("")) { %>
<!-- clase -->
<tr id="dvFliaClase" class="dvFliaClase" style="display:none">
	<td colspan="2" class="TableBottomBorder">
		<table width="100%" align="center">
			<tr class="TextHeader">
			<td align="center" class="">Clase (<%=familia%>)</td></tr>
			<tr>
			<td>

			<%
			sbEvent = new StringBuffer();

			sbSql = new StringBuffer();
			sbSql.append("select B.COD_CLASE, B.DESCRIPCION from tbl_inv_clase_articulo b where b.compania=");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and b.cod_flia=");
			sbSql.append(familia);
			sbSql.append(" and estado_pos = 'A'");
			sbSql.append(" order by 2");
			alFlia = new ArrayList();
			alFlia = SQLMgr.getDataList(sbSql.toString());
			for (int i=0; i<alFlia.size(); i++){
				CommonDataObject fdo = (CommonDataObject) alFlia.get(i);
				sbEvent = new StringBuffer();
				sbEvent.append(" onClick=\"javascript:setFliaClase(");
				sbEvent.append(fdo.getColValue("COD_CLASE"));
				sbEvent.append(")\" style=\"cursor:pointer\"");
			%>
			<div class="button-container pull-left">
					<div class="btn btn-xs btn-warning option-button" <%=sbEvent%>>
						<%=(fdo.getColValue("DESCRIPCION").length()>25) ? fdo.getColValue("DESCRIPCION").substring(0,25):fdo.getColValue("DESCRIPCION")%>
					</div>
			</div>
			<% } %>
			</td>
			</tr>
		</table>
	</td>
</tr>
<!-- clase end -->
<% } %>
<tr id="dvArticulo" class="dvArticulo" style="display:<%=(!familia.trim().equals("")?"":"none")%>">
	<td width="100%" class="TableLeftBorder TableRightBorder" colspan="2">
<!-- ================================	R E S U L T S	S T A R T	H E R E	  ================================ -->

		<div class="container" width="100%">
<%
int c_d=0;
sbEvent = new StringBuffer();
for (int i=0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (request.getParameter("search") == null) {
		sbEvent = new StringBuffer();
		sbEvent.append(" onClick=\"javascript:addItem(");
		sbEvent.append(i);
		sbEvent.append(")\" style=\"cursor:pointer\"");
	}

	if (cdo.getColValue("tipo_descuento") != null && !cdo.getColValue("tipo_descuento").trim().equals("") && cdo.getColValue("id_descuento") != null && !cdo.getColValue("id_descuento").trim().equals("")) {
%>
<%=fb.hidden("_desc_cod_articulo"+c_d,cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("_desc_tipo_descuento"+c_d,cdo.getColValue("tipo_descuento"))%>
<%=fb.hidden("_desc_id"+c_d,""+i)%>
<%
	c_d++;
}
%>
<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("descripcion"+i,issi.admin.IBIZEscapeChars.forHTMLTag(cdo.getColValue("descripcion")))%>
<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
<%=fb.hidden("precio_ejecutivo"+i,cdo.getColValue("precio_ejecutivo"))%>
<%=fb.hidden("precio_colaborador"+i,cdo.getColValue("precio_colaborador"))%>
<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
<%=fb.hidden("gravable_perc"+i,cdo.getColValue("gravable_perc"))%>
<%=fb.hidden("precio1_"+i,cdo.getColValue("precio"))%>
<%=fb.hidden("precio2_"+i,cdo.getColValue("precio_ejecutivo"))%>
<%=fb.hidden("precio3_"+i,cdo.getColValue("precio_colaborador"))%>
<%=fb.hidden("precio4_"+i,cdo.getColValue("precio4"))%>
<%=fb.hidden("precio5_"+i,cdo.getColValue("precio5"))%>
<%=fb.hidden("precio6_"+i,cdo.getColValue("precio6"))%>
<%=fb.hidden("precio7_"+i,cdo.getColValue("precio7"))%>
<%=fb.hidden("precio8_"+i,cdo.getColValue("precio8"))%>
<%=fb.hidden("tipo_descuento"+i,cdo.getColValue("tipo_descuento"))%>
<%=fb.hidden("es_combo_adicional"+i,cdo.getColValue("es_combo_adicional"))%>
<%=fb.hidden("combo_colaborador"+i,cdo.getColValue("combo_colaborador"))%>
<%=fb.hidden("total_desc"+i,cdo.getColValue("total_desc"))%>
<%=fb.hidden("id_descuento"+i,cdo.getColValue("id_descuento"))%>
<%=fb.hidden("tipo_articulo"+i,cdo.getColValue("tipo_articulo"))%>
<%=fb.hidden("afecta_inventario"+i,cdo.getColValue("afecta_inventario"))%>
<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
<%=fb.hidden("check_disp"+i,cdo.getColValue("check_disp"))%>
<%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
<%=fb.hidden("cod_barra"+i,cdo.getColValue("cod_barra"))%>
<%=fb.hidden("qty_ini"+i,cdo.getColValue("qty_ini"))%>
<%=fb.hidden("val_desc"+i,cdo.getColValue("val_desc"))%>
<%=fb.hidden("spn"+i, "descripcion="+issi.admin.IBIZEscapeChars.forURL(cdo.getColValue("descripcion"))+"&precio=@precio@&itbm="+cdo.getColValue("itbm")+"&cantidad="+cdo.getColValue("cantidad")+"&codigo_almacen="+cdo.getColValue("codigo_almacen")+"&total_desc="+cdo.getColValue("total_desc")+"&total="+cdo.getColValue("precio")+"&tipo_servicio="+cdo.getColValue("tipo_servicio")+"&gravable_perc="+cdo.getColValue("gravable_perc")+"&precio_ejecutivo="+cdo.getColValue("precio_ejecutivo")+"&precio_colaborador="+cdo.getColValue("precio_colaborador")+"&precio_normal="+cdo.getColValue("precio")+"&tipo_articulo="+cdo.getColValue("tipo_articulo")+"&afecta_inventario="+cdo.getColValue("afecta_inventario")+"&costo="+cdo.getColValue("costo")+"&cod_barra="+cdo.getColValue("cod_barra")+"&qty_ini="+cdo.getColValue("qty_ini")+"&val_desc="+cdo.getColValue("val_desc")+"&use_keypad="+useKeypad)%>
		<div class="button-container pull-left">
					<div class="btn btn-xs btn-primary option-button" <%=cdo.getColValue("item_decoration","btn-primary")%>" <%=sbEvent%>>
						<%=(cdo.getColValue("descripcion").length()>25) ? cdo.getColValue("descripcion").substring(0,25):cdo.getColValue("descripcion")%>
					</div>
				</div>
<%
}

if (al.size() == 0) {
%>
		No registros encontrados.
<% } %>
<%=fb.hidden("sizeDesc",""+c_d)%>
		</div>
<!-- ================================	R E S U L T S	E N D	H E R E	  ================================ -->
	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("tipo_pos",tipo_pos)%>
			<%=fb.hidden("artType",artType)%>
			<%=fb.hidden("almacen",almacen)%>
			<%=fb.hidden("familia",familia)%>
			<%=fb.hidden("art_clase",clase)%>
			<%=fb.hidden("es_menu_dia",es_menu_dia)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("cod_articulo",articulo)%>
			<%=fb.hidden("descripcion",descripcion)%>
			<%=(request.getParameter("search") == null)?"":fb.hidden("search",request.getParameter("search"))%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
			<%=fb.formEnd()%>
			<td width="40%"><!--Total Registro(s) <%//=rowCount%>--></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
			<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("tipo_pos",tipo_pos)%>
			<%=fb.hidden("artType",artType)%>
			<%=fb.hidden("almacen",almacen)%>
			<%=fb.hidden("familia",familia)%>
			<%=fb.hidden("art_clase",clase)%>
			<%=fb.hidden("es_menu_dia",es_menu_dia)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("cod_articulo",articulo)%>
			<%=fb.hidden("descripcion",descripcion)%>
			<%=(request.getParameter("search") == null)?"":fb.hidden("search",request.getParameter("search"))%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	System.out.println("=====================POST=====================");
	int lineNo = htDet.size();
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for(int i=0;i<keySize;i++){
		CommonDataObject det = new CommonDataObject();
		det.addColValue("id_familia", request.getParameter("cod_flia"+i));
		det.addColValue("id_articulo", request.getParameter("cod_articulo"+i));
		det.addColValue("descripcion", request.getParameter("art_desc"+i));
		det.addColValue("cod_barra", request.getParameter("cod_barra"+i));
		det.addColValue("tipo_articulo", request.getParameter("tipo_articulo"+i));
		det.addColValue("id", "0");
		if(request.getParameter("chk"+i)!=null && request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try {
				htDet.put(key, det);
				vDet.addElement(det.getColValue("id_articulo"));
				System.out.println("addget item "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else if(request.getParameter("del"+i)!=null){
			artDel = "1";
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&fp="+fp+"&artType="+artType+"&tipo="+tipo);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	window.opener.document.location = '../pos/reg_caf_menu_det.jsp?change=1';
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>