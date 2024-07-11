<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();


String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String compania 			 = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String aseguradora  	 = request.getParameter("aseguradora");
String tipoServicio  	 = request.getParameter("tipoServicio");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String ts				       = request.getParameter("ts");
String fg				       = request.getParameter("fg");
String tipoFecha = request.getParameter("tipoFecha");
String fp				       = request.getParameter("fp");
String consignacion				       = request.getParameter("consignacion");
String comprob = request.getParameter("comprob");
String afectaConta = request.getParameter("afectaConta");
String printRes = request.getParameter("printRes")==null?"":request.getParameter("printRes");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String codFlia = request.getParameter("codFlia");
String wh = request.getParameter("wh"); 
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String aseg = request.getParameter("pAseguradora");
String descAseg = request.getParameter("pDescAseg");
StringBuffer sbSql = new StringBuffer();
if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (tipoServicio == null) tipoServicio = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (ts == null) ts = "";
if (fg == null) fg = "";
if (tipoFecha == null) tipoFecha = "";
if (fp == null) fp = "";
if (consignacion == null) consignacion = "";
if (comprob == null) comprob = "";
if (afectaConta == null) afectaConta = "";
if (codFlia == null)     codFlia       = "";
if (wh == null)     wh       = ""; 
//if (consignacion == "ALL") consignacion = "";
if (pacId == null)pacId= "";
if (admision == null)admision= "";
if (aseg == null)aseg= "";
if (descAseg == null)descAseg= "";
StringBuffer appendFilter1 = new StringBuffer();
//--------------Parámetros--------------------//
if (!fechaini.equals(""))
   {
   	if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and fdt.fecha_creacion >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
		}
   }
if (!fechafin.equals(""))
   {
		if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and fdt.fecha_creacion <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
		}
   }
if (!aseg.equals("")&&!aseg.equals("ALL")){ 
	appendFilter1.append("and exists (select 'x' from tbl_adm_beneficios_x_admision aba where aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A'");
	appendFilter1.append(" and aba.pac_id = fdt.pac_id and aba.admision = fdt.fac_secuencia  and rownum = 1 and aba.empresa = ");
	appendFilter1.append(aseg);
	appendFilter1.append(" ) ");
}
if (!centroServicio.equals(""))
   {
    if(cdsDet.trim().equals("S")){
			appendFilter1.append(" and fdt.centro_servicio = ");
			appendFilter1.append(centroServicio); 
		} else {
			appendFilter1.append(" and ft.centro_servicio = ");
			appendFilter1.append(centroServicio);
		}
	 }
if (!compania.equals(""))
  {
   appendFilter1.append(" and fdt.compania = ");
	 appendFilter1.append(compania);
  }
if (!categoria.equals(""))
   {
   	appendFilter1.append(" and aa.categoria = ");
		appendFilter1.append(categoria);
   }
if (!ts.equals(""))
   {
   	appendFilter1.append(" and fdt.tipo_cargo = '");
		appendFilter1.append(ts);
		appendFilter1.append("'");
   }
if (!pacId.equals(""))
{
appendFilter1.append(" and fdt.pac_id =");
appendFilter1.append(pacId); 
}
if (!admision.equals(""))
{
appendFilter1.append(" and fdt.fac_secuencia =");
appendFilter1.append(admision); 
}

/*if(!consignacion.equals("")&&!consignacion.equals("ALL"))
{
appendFilter1.append(" and a.consignacion_sino ='");
appendFilter1.append(consignacion);
appendFilter1.append("'"); 
}*/
if(!comprob.equals(""))
{
appendFilter1.append(" and nvl(fdt.comprobante,'N') ='");
appendFilter1.append(comprob);
appendFilter1.append("'"); 
}
 
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos---------------------------------//
sbSql.append(" select all c.descripcion as centroServicio, p.nombre_paciente as nombrePaciente, ft.pac_id||' - '||ft.admi_secuencia as codigoPaciente, to_char(fdt.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(fdt.fecha_cargo,'dd/mm/yyyy') as fechaCargo, fdt.tipo_cargo as tipoCargo, decode(fdt.tipo_transaccion, 'H', fdt.descripcion || ' ' || fdx_find_medico(ft.med_codigo, ft.empre_codigo, null), fdt.descripcion) as descCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)) cantTransaccion, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.monto, 0)) montoCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.recargo, 0)) montoRecargo, sum(nvl(decode(fdt.tipo_transaccion,'D',-fdt.cantidad,fdt.cantidad),0) * nvl(fdt.costo_art,0)) montoCosto from tbl_fac_transaccion ft,  tbl_fac_detalle_transaccion fdt, vw_adm_paciente p, tbl_adm_admision aa, tbl_cds_centro_servicio c where fdt.fac_codigo=ft.codigo and fdt.fac_secuencia=ft.admi_secuencia  and fdt.pac_id=ft.pac_id and fdt.compania=ft.compania  and fdt.tipo_transaccion=ft.tipo_transaccion  and aa.pac_id = ft.pac_id  and aa.secuencia = ft.admi_secuencia  and ft.pac_id = p.pac_id ");
if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = c.codigo ");
else sbSql.append(" and ft.centro_servicio = c.codigo ");
//if(!consignacion.trim().equals("") && !consignacion.trim().equals("ALL")){sbSql.append(" and ar.consignacion_sino = '");sbSql.append(consignacion);sbSql.append("'");}
sbSql.append(appendFilter1.toString());
sbSql.append("   group by c.descripcion, p.nombre_paciente,ft.pac_id||' - '||ft.admi_secuencia,  fdt.fecha_creacion, fdt.fecha_cargo, fdt.tipo_cargo,  decode(fdt.tipo_transaccion, 'H', fdt.descripcion || ' ' || fdx_find_medico(ft.med_codigo, ft.empre_codigo, null), fdt.descripcion) order by c.descripcion,p.nombre_paciente, ft.pac_id||' - '||ft.admi_secuencia, fdt.fecha_creacion ");

if(fg.trim().equals("COSTO")&&fp.trim().equals("COSTOPAC"))
{
sbSql = new StringBuffer();
sbSql.append(" select all c.descripcion as centroServicio,p.nombre_paciente as nombrePaciente, ft.pac_id||' - '||ft.admi_secuencia as codigoPaciente, to_char(fdt.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(fdt.fecha_cargo,'dd/mm/yyyy') as fechaCargo, fdt.tipo_cargo as tipoCargo,fdt.descripcion as descCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)) cantTransaccion, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.monto, 0)) montoCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.recargo, 0)) montoRecargo, nvl(sum(round (decode(fdt.tipo_transaccion,'C',(fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.inv_almacen,fdt.inv_articulo,to_char(fdt.fecha_creacion,'mm'),to_char(fdt.fecha_creacion,'yyyy'),nvl(fdt.costo_art,0),null) from dual ))),'D',-1*(fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.inv_almacen,fdt.inv_articulo,to_char(fdt.fecha_creacion,'mm'),to_char(fdt.fecha_creacion,'yyyy'),nvl(fdt.costo_art,0),null) from dual )))),2)),0) montoCosto ");
if(fp.trim().equals("COSTOPAC"))
{
/*sbSql.append(",(select cg.descripcion from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6 = nvl((select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =");
  if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
  else sbSql.append("ft.centro_servicio ");
sbSql.append(" and acc.service_type = fdt.tipo_cargo and acc.acctype_id =3 and acc.status ='A' and acc.def_type ='S' and acc.adm_type in (select adm_type from tbl_adm_categoria_admision where codigo=(select categoria from tbl_adm_admision where pac_id =ft.pac_id and secuencia=ft.admi_secuencia)) and compania=fdt.compania),(select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =");
  if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
  else sbSql.append("ft.centro_servicio ");
sbSql.append(" and acc.service_type = fdt.tipo_cargo and acc.acctype_id =3 and acc.status ='A' and acc.def_type ='S' and acc.adm_type in ('T') and compania=fdt.compania)) and cg.compania =fdt.compania ) descCuenta ");

sbSql.append(" ,nvl(nvl((select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =");
  if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
  else sbSql.append("ft.centro_servicio ");
sbSql.append(" and acc.service_type = fdt.tipo_cargo and acc.acctype_id =3 and acc.status ='A' and acc.def_type ='S' and acc.adm_type in (select adm_type from tbl_adm_categoria_admision where codigo=(select categoria from tbl_adm_admision where pac_id =ft.pac_id and secuencia=ft.admi_secuencia)) and compania=fdt.compania),(select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =");
  if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
  else sbSql.append("ft.centro_servicio ");
sbSql.append(" and acc.service_type = fdt.tipo_cargo and acc.acctype_id =3 and acc.status ='A' and acc.def_type ='S' and acc.adm_type in ('T') and compania=fdt.compania)),'S/C') cuenta");*/

 sbSql.append(",nvl((select cg.descripcion from tbl_con_catalogo_gral cg where cg.cta1||'-'||cg.cta2||'-'||cg.cta3||'-'||cg.cta4||'-'||cg.cta5||'-'||cg.cta6 = nvl((select getMapingCta('CARGDEVCOST',fdt.compania,");
 
 if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
 else sbSql.append("ft.centro_servicio ");

 sbSql.append(",fdt.tipo_cargo,'-','-',ft.adm_type)  from dual),'S/C') and cg.compania =fdt.compania ),'S/NOMBRE') descCuenta ");
sbSql.append(", nvl((select getMapingCta('CARGDEVCOST',fdt.compania,");
if(cdsDet.trim().equals("S"))sbSql.append("fdt.centro_servicio "); 
  else sbSql.append("ft.centro_servicio ");
sbSql.append(",fdt.tipo_cargo,'-','-',ft.adm_type)  from dual),'S/C') as cuenta");
}

sbSql.append(" from tbl_fac_transaccion ft,  tbl_fac_detalle_transaccion fdt, vw_adm_paciente p, tbl_adm_admision aa, tbl_cds_centro_servicio c ,tbl_inv_inventario inv,tbl_inv_articulo ar ");
  sbSql.append(" where fdt.fac_codigo=ft.codigo and fdt.fac_secuencia=ft.admi_secuencia  and fdt.pac_id=ft.pac_id  and fdt.compania=ft.compania  and fdt.tipo_transaccion=ft.tipo_transaccion  and aa.pac_id = ft.pac_id  and aa.secuencia = ft.admi_secuencia  and ft.pac_id = p.pac_id ");
  if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = c.codigo ");
  else sbSql.append(" and ft.centro_servicio = c.codigo");
//  sbSql.append("   and fdt.tipo_cargo  IN ('02','03','04') ");
sbSql.append(appendFilter1.toString());
sbSql.append("  and ( inv.cod_articulo  = fdt.inv_articulo and  inv.compania= fdt.compania and inv.codigo_almacen = fdt.inv_almacen) and (fdt.inv_articulo  = ar.cod_articulo and  fdt.compania      = ar.compania)");
if(!afectaConta.trim().equals("")){sbSql.append(" and fdt.afecta_conta = '");sbSql.append(afectaConta);sbSql.append("'");}
if(!consignacion.trim().equals("") && !consignacion.trim().equals("ALL")){sbSql.append(" and ar.consignacion_sino = '");sbSql.append(consignacion);sbSql.append("'");}
if(!wh.trim().equals("")){sbSql.append(" and fdt.inv_almacen = ");sbSql.append(wh);}
if(!codFlia.trim().equals("")){sbSql.append(" and fdt.art_familia  = ");sbSql.append(codFlia);}
  sbSql.append(" group by ft.adm_type,c.descripcion,p.nombre_paciente, ft.pac_id||' - '||ft.admi_secuencia,  fdt.fecha_creacion, fdt.fecha_cargo, fdt.tipo_cargo,    fdt.descripcion");
  if(fp.trim().equals("COSTOPAC")){sbSql.append(", fdt.compania,ft.pac_id,ft.admi_secuencia");
  if(cdsDet.trim().equals("S"))sbSql.append(",fdt.centro_servicio "); 
  else sbSql.append(",ft.centro_servicio ");}
  
   sbSql.append(" order by c.descripcion, p.nombre_paciente,ft.pac_id||' - '||ft.admi_secuencia,fdt.fecha_creacion ");
}
else if(fp.trim().equals("COSTOINV"))
{

sbSql =new StringBuffer();

 sbSql.append(" select all al.descripcion as centroServicio, p.nombre_paciente as nombrePaciente, ft.pac_id||' - '||ft.admi_secuencia as codigoPaciente, to_char(fdt.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(fdt.fecha_cargo,'dd/mm/yyyy') as fechaCargo, fdt.tipo_cargo as tipoCargo,fdt.inv_articulo||' - '||fdt.descripcion as descCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)) cantTransaccion, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.monto, 0)) montoCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.recargo, 0)) montoRecargo, nvl(sum(round (decode(fdt.tipo_transaccion,'C',(fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.inv_almacen,fdt.inv_articulo,to_char(fdt.fecha_creacion,'mm'),to_char(fdt.fecha_creacion,'yyyy'),nvl(fdt.costo_art,0),null) from dual ))),'D',-1*(fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.inv_almacen,fdt.inv_articulo,to_char(fdt.fecha_creacion,'mm'),to_char(fdt.fecha_creacion,'yyyy'),nvl(fdt.costo_art,0),null) from dual )))),2)),0) montoCosto,(select num_cuenta from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6=nvl((select getCtaFlia(fdt.compania,al.codigo_almacen,fdt.art_familia,-1) from dual),al.cg_cta1||'.'||al.cg_cta2||'.'||nvl(ff.nivel,al.cg_cta3)||'.'||al.cg_cta4||'.'||al.cg_cta5||'.'||al.cg_cta6) and compania = fdt.compania)  cuenta,(select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6=nvl((select getCtaFlia(fdt.compania,al.codigo_almacen,fdt.art_familia,-1) from dual ),al.cg_cta1||'.'||al.cg_cta2||'.'||nvl(ff.nivel,al.cg_cta3)||'.'||al.cg_cta4||'.'||al.cg_cta5||'.'||al.cg_cta6) and compania = fdt.compania) descCuenta,ff.nombre descFlia ");
sbSql.append(" ,ft.seq_trx  as fac_codigo ");
 sbSql.append(" from tbl_fac_transaccion ft,  tbl_fac_detalle_transaccion fdt, vw_adm_paciente p, tbl_adm_admision aa, tbl_inv_inventario inv ,tbl_inv_almacen al ,tbl_inv_articulo a, tbl_cds_centro_servicio cds,tbl_inv_familia_articulo ff where fdt.fac_codigo=ft.codigo and fdt.fac_secuencia=ft.admi_secuencia  and fdt.pac_id=ft.pac_id and fdt.compania=ft.compania  and fdt.tipo_transaccion=ft.tipo_transaccion  and aa.pac_id = ft.pac_id and aa.secuencia = ft.admi_secuencia  and ft.pac_id = p.pac_id ");
 
 if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = cds.codigo");
else  sbSql.append(" and ft.centro_servicio = cds.codigo");
sbSql.append(appendFilter1.toString());
if(!afectaConta.trim().equals("")){sbSql.append(" and fdt.afecta_conta = '");sbSql.append(afectaConta);sbSql.append("'");}
if(!consignacion.trim().equals("")&& !consignacion.trim().equals("ALL")){sbSql.append(" and a.consignacion_sino = '");sbSql.append(consignacion);sbSql.append("'");}
if(!wh.trim().equals("")){sbSql.append(" and fdt.inv_almacen = ");sbSql.append(wh);}
if(!codFlia.trim().equals("")){sbSql.append(" and fdt.art_familia  = ");sbSql.append(codFlia);}
sbSql.append(" and (inv.cod_articulo  = fdt.inv_articulo and  inv.compania= fdt.compania and inv.codigo_almacen = fdt.inv_almacen)  ");
//sbSql.append(" and fdt.tipo_cargo  IN ('02','03','04')");
sbSql.append(" and ( fdt.inv_articulo  = a.cod_articulo and  fdt.compania      = a.compania)  and (inv.cod_articulo  = a.cod_articulo and  inv.compania = a.compania and inv.codigo_almacen    = fdt.inv_almacen ) and (al.codigo_almacen=fdt.inv_almacen and al.compania = ft.compania )and (fdt.compania = ff.compania and fdt.art_familia = ff.cod_flia) ");
if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = cds.codigo");
else  sbSql.append(" and ft.centro_servicio = cds.codigo");
 
sbSql.append(" group by al.descripcion, p.nombre_paciente, ft.pac_id||' - '||ft.admi_secuencia,  fdt.fecha_creacion, fdt.fecha_cargo, fdt.tipo_cargo, fdt.inv_articulo||' - '||fdt.descripcion,al.cg_cta1||'.'||al.cg_cta2||'.'||NVL(ff.nivel,al.cg_cta3)||'.'||al.cg_cta4||'.'||al.cg_cta5||'.'||al.cg_cta6, fdt.compania,ff.nombre ,al.codigo_almacen,fdt.art_familia,ft.seq_trx ");
  
sbSql.append(" order by al.descripcion,ff.nombre,p.nombre_paciente, ft.pac_id||' - '||ft.admi_secuencia, fdt.fecha_creacion");

}

if(printRes.trim().equals("")) al = SQLMgr.getDataList(sbSql.toString());
else if(printRes.trim().equals("S")) {
al = SQLMgr.getDataList("select aa.centroservicio, sum(aa.canttransaccion) cantCentro, sum(aa.montocargo) montocargo , sum(aa.montorecargo) montorecargo, sum(aa.montocosto) montocosto, 0 cantTransaccion from( "+sbSql.toString()+")aa group by aa.centroservicio order by 1");


}

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

  if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

  String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = printRes.trim().equals("");
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "";
	if(fg.trim().equals("COSTO"))title = "COSTO EN CONSUMO DE PACIENTES "+(printRes.equals("S")?"\n(RESUMIDO POR CDS)":"");
	else title = "CONSUMO - DETALLE DE CARGOS Y DEV. A PACIENTES "+(printRes.equals("S")?"\n(RESUMIDO POR CDS)":"");
	
	if(fg.trim().equals("COSTO"))
		if(fp.trim().equals("COSTOPAC"))title += " POR CENTRO";
		else if(fp.trim().equals("COSTOINV"))title += " POR ALMACEN";
	
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin+"    -     "+descAseg;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
	  if (printRes.trim().equals("")){
        if (fp.trim().equalsIgnoreCase("COSTOINV")){
            dHeader.addElement(".08");
            dHeader.addElement(".08");
            dHeader.addElement(".05");
            dHeader.addElement(".09");
        }else{
            dHeader.addElement(".10");
            dHeader.addElement(".10");
            dHeader.addElement(".05");
        }
        
        
		if(fg.trim().equals("COSTO")&& !fp.trim().equals("COSTOPAC"))dHeader.addElement(".35");
		else if(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))dHeader.addElement(".25");
		else dHeader.addElement(".45");
		dHeader.addElement(".06");
		if(fg.trim().equals("COSTO"))dHeader.addElement(".10");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
         if (fp.equals("COSTOINV")) dHeader.addElement(".25");
         else dHeader.addElement(".30");
        }
	  }else if (printRes.trim().equals("S")){
		  if(fg.trim().equals("COSTO")) dHeader.addElement(".30");
		  else dHeader.addElement(".40");
		  dHeader.addElement(".20");
		  if(fg.trim().equals("COSTO")) dHeader.addElement(".10");
		  dHeader.addElement(".20");
		  dHeader.addElement(".20");
	  }

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(1);

	 if (printRes.trim().equals("")){
		pc.addBorderCols("F.Creación",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("F.Cargo",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("T.Cargo",1,1,cHeight,Color.lightGray);
        
        if (fp.trim().equalsIgnoreCase("COSTOINV")){
          pc.addBorderCols("Trx.",1,1,cHeight,Color.lightGray);
        }
        
		pc.addBorderCols("Descripción del Cargo",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("Cantidad",1,1,cHeight,Color.lightGray);
		if(fg.trim().equals("COSTO")) pc.addBorderCols("Costo",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("Monto Cargo",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("Monto Recargo",1,1,cHeight,Color.lightGray);
		if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV")))pc.addBorderCols("Cuenta",1,1,cHeight,Color.lightGray);
	}else if (printRes.trim().equals("S")){
	    pc.addBorderCols("Centro Servicio",0,1,cHeight,Color.lightGray);
		pc.addBorderCols("Cantidad",1,1,cHeight,Color.lightGray);
		if(fg.trim().equals("COSTO")) pc.addBorderCols("T.Costo",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("T.Cargo",2,1,cHeight,Color.lightGray);
		pc.addBorderCols("T.Recargo",2,1,cHeight,Color.lightGray);
	}
	
	
	String groupByCentro	= "";		// para agrupar por centro servicio.
	String groupByPacte		= "";		// para agrupar por paciente
	String groupByFlia 		= "";		// para agrupar por Familia	
	double centroCargo 		= 0,pacteCargo= 0,finalCargo= 0;	// para el monto de cargos
	double centroRecargo 	= 0,  pacteRecargo 	= 0, 	finalRecargo 	= 0;	// para el monto de recargos
	double pacteCosto=0,centroCosto=0,finalCosto=0;//Para costo de articulos...
	int		 centroCant 		= 0, 	pacteCant 		= 0, 	finalCant 		= 0,fliaCant=0;
	double fliaCargo = 0,fliaRecargo = 0,fliaCosto= 0;
	
	if (printRes.trim().equals("")){
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por grupo de aseguradora
		if (!groupByCentro.trim().equalsIgnoreCase(cdo.getColValue("centroServicio")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0)  // imprime total de pacte
					{
						// total de cargos por paciente
						if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
                        else pc.addCols("TOTAL POR PACIENTE. . . . . ",2,4);
                        
						pc.addCols(String.valueOf(pacteCant),1,1);
						if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCosto),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
						if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                          pc.addCols(" ",2,1);
                        }
						pc.addCols(" ",0,dHeader.size(),cHeight);
						
						// total de cargos por familia
						if(fp.trim().equals("COSTOINV"))
						{
							pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
							pc.addCols(String.valueOf(fliaCant),1,1);
							if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
							pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCargo),2,1);
							pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaRecargo),2,1);
							if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV")))pc.addCols(" ",2,1);
							pc.addCols(" ",0,dHeader.size(),cHeight);
						}
						// consumo de la aseguradora
						if(fp.trim().equals("COSTOINV")) pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,5);
                        else pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,4);
						pc.addCols(String.valueOf(centroCant),1,1);
						if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCosto),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroRecargo),2,1);
						if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV")))
                        {
                          pc.addCols(" ",2,1);
                        }
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(cdo.getColValue("centroServicio"),0,dHeader.size());
					centroCargo 	= 0;
					centroRecargo   = 0;
					centroCant 		= 0;
					centroCosto	    = 0;
					// para acumular totales del paciente
					pacteCargo 		= 0;
					pacteRecargo 	= 0;
					pacteCant 		= 0;
					pacteCosto      = 0;
					// para acumular totales del Familia
					fliaCargo 		= 0;
					fliaRecargo 	= 0;
					fliaCant 		= 0;
					fliaCosto       = 0;				
					
					groupByCentro 	= "";
					groupByPacte	= "";
					groupByFlia     = "";
		}
		if(fp.trim().equals("COSTOINV"))
		{
			if (!groupByFlia.trim().equalsIgnoreCase(cdo.getColValue("descFlia")+"-"+cdo.getColValue("centroServicio")))
			{
					if (i != 0 && !groupByPacte.trim().equalsIgnoreCase(""))  // imprime total de pacte
					{
						// total de cargos por paciente
						if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
                        else pc.addCols("TOTAL POR PACIENTE. . . . . ",2,4);
						pc.addCols(String.valueOf(pacteCant),1,1);
						if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCosto),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
						if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                          pc.addCols(" ",2,1);
                        }
						pc.addCols(" ",0,dHeader.size(),cHeight);
						pacteCargo 		= 0;
						pacteRecargo 	= 0;
						pacteCant 		= 0;
						groupByPacte		= "";
						
				  }
						pc.setFont(8, 1,Color.black);
						if (i != 0 && !groupByFlia.trim().equalsIgnoreCase(""))  // imprime total de Familia
						{
							// total de cargos por familia
							
								if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
                                else pc.addCols("TOTAL POR FAMILIA. . . . . ",2,4);
								pc.addCols(String.valueOf(fliaCant),1,1);
								if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
								pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCargo),2,1);
								pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaRecargo),2,1);
								if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                                  pc.addCols(" ",2,1);
                                }
								pc.addCols(" ",0,dHeader.size(),cHeight);
					  	}
	
						pc.addCols(cdo.getColValue("descFlia"),0,dHeader.size());
						// para acumular totales del paciente
						fliaCargo 		= 0;
						fliaRecargo 	= 0;
						fliaCant 		= 0;
						groupByFlia		= "";
			}
		}
		// Agrupar Paciente
		if (!groupByPacte.trim().equalsIgnoreCase(cdo.getColValue("nombrePaciente")+" - "+cdo.getColValue("codigoPaciente")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0 && !groupByPacte.trim().equalsIgnoreCase(""))  // imprime total de pacte
					{
						// total de cargos por paciente
						if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
                        else pc.addCols("TOTAL POR PACIENTE. . . . . ",2,4);
						pc.addCols(String.valueOf(pacteCant),1,1);
						if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCosto),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
						if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                           pc.addCols(" ",2,1);
                        }
						pc.addCols(" ",0,dHeader.size(),cHeight);
						
				  }

					if(fg.trim().equals("COSTO"))pc.addCols(cdo.getColValue("nombrePaciente"),0,5);
					else pc.addCols(cdo.getColValue("nombrePaciente"),0,4);
					pc.addCols("Admision: "+cdo.getColValue("codigoPaciente"),0,3);
					if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                       if (fp.equals("COSTOINV")) pc.addCols(" ",2,2);
                       else pc.addCols(" ",2,1);
                    }
                    
					// para acumular totales del paciente
					pacteCargo 		= 0;
					pacteRecargo 	= 0;
					pacteCant 		= 0;
					pacteCosto 		= 0;
					groupByPacte		= "";
		}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("fechaCreacion"),0,1);
		pc.addCols(cdo.getColValue("fechaCargo"),0,1);
		pc.addCols(cdo.getColValue("tipoCargo"),0,1);
        
        if (fp.equals("COSTOINV")) {
          pc.addCols(cdo.getColValue("fac_codigo"),0,1);
        }
        
		pc.addCols(cdo.getColValue("descCargo"),0,1);
		pc.addCols(cdo.getColValue("cantTransaccion"),1,1);
		if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("montoCosto"))),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("montoCargo"))),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("montoRecargo"))),2,1);
		if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))) 
        {
           pc.addCols(cdo.getColValue("cuenta")+" - "+cdo.getColValue("descCuenta"),0,1);
        }
        
		pacteCargo 		+= Double.parseDouble(cdo.getColValue("montoCargo"));
		finalCargo 		+= Double.parseDouble(cdo.getColValue("montoCargo"));
		centroCargo 	+= Double.parseDouble(cdo.getColValue("montoCargo"));
		fliaCargo 		+= Double.parseDouble(cdo.getColValue("montoCargo"));		
		
		pacteRecargo 	+= Double.parseDouble(cdo.getColValue("montoRecargo"));
		centroRecargo   += Double.parseDouble(cdo.getColValue("montoRecargo"));
		fliaRecargo 	+= Double.parseDouble(cdo.getColValue("montoRecargo"));
		finalRecargo 	+= Double.parseDouble(cdo.getColValue("montoRecargo"));
		
		pacteCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
    	centroCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		fliaCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		finalCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		
		pacteCosto 		+= Double.parseDouble(cdo.getColValue("montoCosto"));
		centroCosto 	+= Double.parseDouble(cdo.getColValue("montoCosto"));
		fliaCosto 		+= Double.parseDouble(cdo.getColValue("montoCosto"));
		finalCosto 		+= Double.parseDouble(cdo.getColValue("montoCosto"));

		groupByCentro	= cdo.getColValue("centroServicio");
		groupByPacte 	= cdo.getColValue("nombrePaciente")+" - "+cdo.getColValue("codigoPaciente");
		groupByFlia     = cdo.getColValue("descFlia")+"-"+cdo.getColValue("centroServicio");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{

			pc.setFont(8, 1,Color.black);
			// total de cargos por paciente
			if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
            else pc.addCols("TOTAL POR PACIENTE. . . . . ",2,4);
			pc.addCols(String.valueOf(pacteCant),1,1);
			if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCosto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
			if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
              pc.addCols(" ",2,1);
            }
			pc.addCols(" ",0,dHeader.size(),cHeight);
			//Total por Familia
			if(fp.trim().equals("COSTOINV"))
			{
				pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
				pc.addCols(String.valueOf(fliaCant),1,1);
				if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCargo),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaRecargo),2,1);
				if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
                  pc.addCols(" ",2,1);
                }
				pc.addCols(" ",0,dHeader.size(),cHeight);
			}
			// consumo del centro
			if (fp.equals("COSTOINV")) pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,5);
			else pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,4);
			pc.addCols(String.valueOf(centroCant),1,1);
			if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCosto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroRecargo),2,1);
			if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
              if (fp.equals("COSTOINV")) pc.addCols(" ",2,2);
              else pc.addCols(" ",2,1);
            }
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo final
			if (fp.equals("COSTOINV"))pc.addCols("T O T A L E S   F I N A L E S . . . . . ",2,5);
			else pc.addCols("T O T A L E S   F I N A L E S . . . . . ",2,4);
			pc.addCols(String.valueOf(finalCant),1,1);
			if(fg.trim().equals("COSTO"))pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalCosto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalRecargo),2,1);
			if(fg.trim().equals("COSTO")&&(fp.trim().equals("COSTOPAC")||fp.trim().equals("COSTOINV"))){
              pc.addCols(" ",2,1);
            }
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	 }else if(printRes.trim().equals("S")){
	    finalCosto = 0.0;finalCargo = 0.0; finalRecargo = 0.0; finalCant = 0;
		
		pc.setFont(8,0);
	    for (int i=0; i<al.size(); i++){
		  cdo = (CommonDataObject) al.get(i);
		  pc.addCols(cdo.getColValue("centroservicio"),0,1);
		  pc.addCols(cdo.getColValue("cantCentro"),1,1);
		  if(fg.trim().equals("COSTO"))
		    pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montoCosto")),2,1);
		  pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montocargo")),2,1);
		  pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montorecargo")),2,1);
		  
		  finalCant += Integer.parseInt(cdo.getColValue("cantCentro"));
		  finalCargo += Double.parseDouble(cdo.getColValue("montoCargo"));
		  finalRecargo += Double.parseDouble(cdo.getColValue("montoRecargo"));
		  finalCosto += Double.parseDouble(cdo.getColValue("montoCosto"));
		}
		
		pc.setFont(8,1);
		pc.addCols("Totales Finales",0,1);
		pc.addCols(String.valueOf(finalCant),1,1);
		  if(fg.trim().equals("COSTO"))
		    pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",String.valueOf(finalCosto)),2,1);
		  pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",String.valueOf(finalCargo)),2,1);
		  pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",String.valueOf(finalRecargo)),2,1);
	  }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
