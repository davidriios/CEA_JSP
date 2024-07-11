<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.File" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCarCot" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCarCot" scope="session" class="java.util.Vector"/>

<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
StringBuffer sql=new StringBuffer();
CommonDataObject cdoEnc = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String key="";
String id= request.getParameter("id");
String renglon=request.getParameter("renglon"); 
String mode=request.getParameter("mode"); 
String fp = request.getParameter("fp"); 
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String wh = request.getParameter("wh");
boolean viewMode = false;
boolean viewModeEdit = false;
String cs = request.getParameter("cs");

ArrayList al= new ArrayList();
ArrayList alCds = new ArrayList();
String change= request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if(cs ==null)cs="";
if(mode ==null)mode="add";
if(mode.trim().equals("view"))viewMode=true; 
if(id ==null)id="";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (wh == null) wh = "";
if (fp == null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		alCds = sbb.getBeanList(ConMgr.getConnection()," select codigo  as optValueColumn, descripcion as optLabelColumn from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))    ",CommonDataObject.class);
		
		XMLCreator xml = new XMLCreator(ConMgr);

if(!UserDet.getUserProfile().contains("0")){
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a,tbl_sec_user_almacen b where a.almacen=b.almacen and a.compania =b.compania  and b.ref_type='CDS' and b.user_id="+UserDet.getUserId()+" order by a.compania,a.cds,b.user_id,a.almacen");}
	else{xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a order by a.compania, a.cds, a.almacen");}

iCarCot.clear();
vCarCot.clear();		
		
if(!id.trim().equals(""))
{
		sql.append("select id, decode(esPac,'S',(select nombre_paciente from vw_adm_paciente where pac_id = c.pac_id),nombre) as nombre, estado, observacion, usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion,identificacion, to_char(fecha_nac,'dd/mm/yyyy') as fecha_nac , to_char(fecha,'dd/mm/yyyy')  as fecha,medico,procedimiento,other1,other2,other3,esPac,(select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)  from tbl_adm_medico where codigo=c.medico ) as nombreMedico,cod_proc,pac_id,nvl(get_sec_comp_param(c.compania,'FACT_APLICA_ITBMS_ANTES_DESC'),'N') aplicaItbms,(select count(*) from tbl_fac_cotizacion_item where id=c.id and estado ='V') as regValidado,(select count(*) from tbl_fac_cotizacion_item where id=c.id and estado ='V' and cargar='S') as cargar,(select count(*) from tbl_fac_cotizacion_item where id=c.id and estado ='C') as cargado,(select count(*) from tbl_fac_cotizacion_item where id=c.id and estado ='C' and exists (select null from tbl_fac_detalle_transaccion where pac_id ="+pacId+" and fac_secuencia ="+noAdmision+" and ref_type=c.reg_type and ref_id=c.id )) as cargadoPaq ,reg_type,nvl(get_sec_comp_param(c.compania,'FACT_CARGO_PAQ_EDIT'),'N') as actualizarPaq,nvl(get_sec_comp_param(c.compania,'FACT_CARGO_COT_EDIT'),'N') as actualizarCot from tbl_fac_cotizacion c where id=");
		sql.append(id);

		cdoEnc = SQLMgr.getData(sql.toString());
		if((!cdoEnc.getColValue("cargado").trim().equals("0")&& cdoEnc.getColValue("reg_type").trim().equals("COT") ) ||(!cdoEnc.getColValue("cargadoPaq").trim().equals("0")&& cdoEnc.getColValue("reg_type").trim().equals("PAQ") )  )
		{
			viewMode = true;
		}
		if(cdoEnc.getColValue("reg_type").trim().equals("PAQ")&&cdoEnc.getColValue("actualizarPaq").trim().equals("N"))viewModeEdit = true;
		else if(cdoEnc.getColValue("reg_type").trim().equals("COT")&&cdoEnc.getColValue("actualizarCot").trim().equals("N"))viewModeEdit = true;
  
			sql=new StringBuffer();	
sql.append("select  t.id, t.renglon, t.codigo,t.descripcion, t.cantidad, t.precio,t.precioitem, t.descuento, t.tipo_des,t.other1, t.other2,t.trabajo, t.cds, t.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo =t.tipo_servicio) as descTs ,t.keycargo,decode(t.keycargo,'ART',(select other3 from tbl_inv_articulo where cod_articulo = t.trabajo),'N') as afectaInv,t.estado,t.disponible,t.msg,t.wh,t.cargar from tbl_fac_cotizacion_item t where t.tipo_servicio <> get_sec_comp_param(t.compania,'COD_TIPO_SERV_HAB') and id= ");
sql.append(id);/*
sql.append(" and t.renglon =");
sql.append(renglon); */
sql.append("order by t.cds,t.tipo_servicio,t.keycargo "); 

		al=SQLMgr.getDataList(sql.toString()); 
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");

				iCarCot.put(cdo2.getKey(),cdo2);
				vCarCot.add(cdo2.getColValue("trabajo")+"-"+cdo2.getColValue("keycargo"));
			}
 
}
else
{
	cdoEnc.addColValue("nombre","");
	cdoEnc.addColValue("cargar","0");
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="<%=(fp.trim().equals("COT"))?"Cargos Cotizacion":"Cargos Paquetes"%> - "+document.title;
function selCotizacion(){abrir_ventana1('../common/sel_cotizacion.jsp?fp=cotizacion&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fp%>');}
function doAction(){}
function printCotizacionDet(){abrir_ventana('../facturacion/print_cotizacion_det.jsp?id=<%=id%>');}
function verifyTs(k)
{//console.log(' cds = ',document.getElementById('cds'+k));
var cds = $("#cds"+k).val();
var ts = $("#tipo_servicio"+k).val();
var nReg = getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_servicios_x_centros','centro_servicio='+cds+' and tipo_servicio= \''+ts+'\'',''); 
if(nReg==0){ CBMSG.warning('El centro de Servicio seleccionado no brinda el tipo de servicio Agregado...,VERIFIQUE!'); $("#cds"+k).val("");}}
$(function(){
  $(".observAyuda").tooltip({
	content: function () {

	  var $i = $(this).data("i");
	  var $type = $(this).data("type");
	  var $title = $($(this).prop('title'));
	  var $content;	 	  
	  if($type == "1" ) $content = $("#observAyudaCont"+$i).val(); 
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
  });
});


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=(fp.trim().equals("COT"))?"CARGOS COTIZACION":"CARGOS PAQUETE"%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  	<!----><tr id="panel0">
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
					<jsp:param name="mode" value="<%=mode%>"></jsp:param>
					<jsp:param name="fp" value="<%=fp%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("renglon",""+renglon)%>
	<%=fb.hidden("keySize",""+iCarCot.size())%> 
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mode",mode)%> 
	<%=fb.hidden("pacId",pacId)%>
	<%=fb.hidden("noAdmision",noAdmision)%>
	<%=fb.hidden("fp",fp)%>
	
	<%//fb.appendJsValidation("if(!checkMonto())error++;");%>

	 
	
	<tr class="TextHeader01">
		<td colspan="3">[<%=id%>]<%=cdoEnc.getColValue("nombre")%></td>
		<td align="right"><%=fb.button("selCot",(fp.trim().equals("COT"))?"COTIZACION":"PAQUETE",false,viewMode,null,null,"onClick=\"javascript:selCotizacion()\"")%></td>
	</tr>
	
	<!--<tr class="TextHeader01">
		<td colspan="3">Centro:<%=fb.select(ConMgr.getConnection(),"select codigo  as optValueColumn, descripcion as optLabelColumn from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))","cs",cs,false,false,0,"Text10",null,null,null,"T")%>
</td>
		<td align="right">&nbsp;</td>
	</tr>-->
			 
	<tr>
		<td colspan="4">
		<table width="100%">
			<tr class="TextHeader" align="center">
				<td width="20%"><cellbytelabel>Centro Servicio</cellbytelabel></td>
				<td width="15%"><cellbytelabel>Almacen</cellbytelabel></td>
				<td width="15%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>
				<td width="25%"><cellbytelabel>Descripcion</cellbytelabel></td>
				<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
				<td width="10%"><!--<cellbytelabel>Precio</cellbytelabel>--></td>
				<td width="5%">Verificado?</td>
			</tr>
	<%
	if(iCarCot.size()>0)
	al=CmnMgr.reverseRecords(iCarCot);
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos =(CommonDataObject) iCarCot.get(key);
	    String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:none\"":"";
		String color=""; 
		if(i%2 == 0) color ="TextRow02";
		else color="TextRow01";		
	%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<%=fb.hidden("tipo_servicio"+i,cdos.getColValue("tipo_servicio"))%>
	<%=fb.hidden("keyCargo"+i,cdos.getColValue("keyCargo"))%>
	<%=fb.hidden("trabajo"+i,cdos.getColValue("trabajo"))%>
	<%=fb.hidden("precioItem"+i,cdos.getColValue("precioItem"))%>
	<%=fb.hidden("codigo"+i,cdos.getColValue("codigo"))%>
	<%=fb.hidden("estado"+i,cdos.getColValue("estado"))%>
	<%=fb.hidden("msg"+i,cdos.getColValue("msg"))%>
	<%=fb.hidden("disponible"+i,cdos.getColValue("disponible"))%>
	<%=fb.hidden("renglon"+i,cdos.getColValue("renglon"))%>
	<%=fb.hidden("cargar"+i,cdos.getColValue("cargar"))%>
	<%=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(cdos.getColValue("msg")==null?"":cdos.getColValue("msg"))+"</label>")%>
	<%=fb.hidden("precio"+i,cdos.getColValue("precio"))%>
	<%
	String evt =""; 
	if(cdos.getColValue("keyCargo").trim().equals("ART"))
	{
	  evt ="onChange=\"loadXML('../xml/almacen_x_cds_"+UserDet.getUserId()+".xml','almacen"+i+"','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','');verifyTs("+i+")\"";
	}
	else evt ="onChange=\"verifyTs("+i+")\"";
	
	%>
	
	<tr class="TextRow01" align="center"<%=style%>>
		<td><%=fb.select("cds"+i,alCds,cdos.getColValue("cds"),false,false,viewModeEdit,0,"Text10","",evt,"","S")%>
		
		
		</td>
		<td>
		<%if(cdos.getColValue("keyCargo").trim().equals("ART")){%>
		<%=fb.select("almacen"+i,cdos.getColValue("wh"),"",false,false,0,null,null,"")%>
							 <script>
								loadXML('../xml/almacen_x_cds_<%=UserDet.getUserId()%>.xml','almacen<%=i%>','<%=cdos.getColValue("wh")%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-<%=cdos.getColValue("cds")%>','KEY_COL','');
							</script>
							
			<%}else{%>				
			<%=fb.hidden("almacen"+i,cdos.getColValue("wh"))%>
			<%}%>
							</td>
		<td><%=fb.textBox("descTs"+i,cdos.getColValue("descTs"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%=fb.textBox("descripcion"+i,cdos.getColValue("descripcion"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%=fb.intBox("cantidad"+i,cdos.getColValue("cantidad"),((cdos.getAction().equalsIgnoreCase("D")||viewModeEdit)?false:true),false,(viewMode||viewModeEdit),15,3)%></td>
		<td><%//=fb.decBox("precio"+i,cdos.getColValue("precio"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,15.2)%></td>
		<td><span class="observAyuda" title="" data-i="<%=i%>" data-type="1"><%=cdos.getColValue("cargar")%></td>
	</tr>

	<%}%>
	</table>
</td>
</tr>

	<tr class="TextRow02">
        <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
		<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
		<%//=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.submit("Actualizar","Actualizar",true,(viewMode),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.submit("Validar","Validar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.submit("Cargar","Cargar",true,(viewMode||(cdoEnc.getColValue("cargar").trim().equals("0"))),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>  </td>
    </tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%if(id.trim().equals("")){fb.appendJsValidation("\n\t error++; CBMSG.warning('Seleccione Cotizacion')\n");}%>
		 <%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{

String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");
String errorCode = "", errorMsg = "";

ArrayList list= new ArrayList();
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";
iCarCot.clear();
vCarCot.clear();
if (baction.equalsIgnoreCase("Actualizar")||baction.equalsIgnoreCase("Guardar"))
{
for(int a=0; a<keySize; a++)
{

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_fac_cotizacion_item");
  cdo1.setWhereClause("id="+id+" and renglon="+request.getParameter("renglon"+a)+" and codigo="+request.getParameter("codigo"+a));

  cdo1.addColValue("id",id);
  cdo1.addColValue("renglon",request.getParameter("renglon"+a));

  cdo1.addColValue("precio",request.getParameter("precio"+a));
  cdo1.addColValue("precioItem",request.getParameter("precioItem"+a));
  cdo1.addColValue("fecha_modificacion","sysdate");
  cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  
  cdo1.addColValue("descTs",request.getParameter("descTs"+a));
  cdo1.addColValue("descripcion",request.getParameter("descripcion"+a));
  cdo1.addColValue("cantidad", request.getParameter("cantidad"+a));
  cdo1.addColValue("trabajo", request.getParameter("trabajo"+a));
  cdo1.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+a));
  cdo1.addColValue("keyCargo",request.getParameter("keyCargo"+a));
  cdo1.addColValue("cds", request.getParameter("cds"+a));
  cdo1.setKey(a); 
  cdo1.setAction(request.getParameter("action"+a));
  cdo1.addColValue("codigo",request.getParameter("codigo"+a)); 
  cdo1.addColValue("wh",request.getParameter("almacen"+a)); 	
  cdo1.addColValue("msg",request.getParameter("msg"+a)); 	 
  
  if(baction.equalsIgnoreCase("Actualizar")){
  cdo1.addColValue("estado","A"); 
  cdo1.addColValue("msg","");
  cdo1.addColValue("cargar","");
  }
  else{ cdo1.addColValue("estado",request.getParameter("estado"+a));cdo1.addColValue("cargar",request.getParameter("cargar"+a));
  cdo1.addColValue("msg",request.getParameter("msg"+a)); }
  cdo1.addColValue("disponible",request.getParameter("disponible"+a)); 
  cdo1.addColValue("pac_id",request.getParameter("pacId"));
  cdo1.addColValue("admision",request.getParameter("noAdmision"));
  
		try
		{
			iCarCot.put(cdo1.getKey(),cdo1);
			vCarCot.add(cdo1.getColValue("trabajo")+"-"+cdo1.getColValue("keyCargo"));
			list.add(cdo1);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
  }//End For 
  /*
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_fac_cotizacion_item");
cdo1.setWhereClause(" id="+id+" and renglon="+renglon);
cdo1.setKey(iCarCot.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
}*/

ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);
errorCode = SQLMgr.getErrCode();
errorMsg  = SQLMgr.getErrMsg();
/*if(errorCode.trim().equals("1"))errorMsg  = "Los Cargos se generaron exitosamente!";
	else errorMsg  = SQLMgr.getErrCode();*/
}//end guardar
else if (baction.equalsIgnoreCase("Validar"))
{

CommonDataObject param = new CommonDataObject();
	param.setSql("call sp_fac_valida_cotizacion(?,?,?)");
	param.addInStringStmtParam(1,id);
	param.addInStringStmtParam(2,(String) session.getAttribute("_companyId"));
	param.addInStringStmtParam(3,(String) session.getAttribute("_userName"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"btnAction="+baction+"&mode="+mode+"fp="+fp);
	param = SQLMgr.executeCallable(param,false,true); 	
	ConMgr.clearAppCtx(null);	
	errorCode = SQLMgr.getErrCode();
	errorMsg  = SQLMgr.getErrCode().equals("1")?"La validación de los cargos fue exitosa!":SQLMgr.getErrCode();
  }
  else if (baction.equalsIgnoreCase("Cargar"))
 {

	CommonDataObject param = new CommonDataObject();
	param.setSql("call sp_fac_generar_cargo_cot(?,?,?,?,?,?)");
	param.addInStringStmtParam(1,id);
	param.addInStringStmtParam(2,(String) session.getAttribute("_companyId"));
	param.addInStringStmtParam(3,(String) session.getAttribute("_userName"));
	param.addInStringStmtParam(4,pacId);
	param.addInStringStmtParam(5,noAdmision);
	param.addInStringStmtParam(6,fp);
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"btnAction="+baction+"&mode="+mode);
	param = SQLMgr.executeCallable(param,false,true); 		
	errorCode = SQLMgr.getErrCode();	
	if(errorCode.trim().equals("1"))errorMsg  = "Los Cargos se generaron exitosamente!";
	else errorMsg  = SQLMgr.getErrCode();
	ConMgr.clearAppCtx(null);	
  }

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
<%

	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/descuento_ajuste.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/descuento_list.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/facturacion/reg_cotizacion.jsp?id=<%=id%>&mode=<%=mode%>&renglon=<%=renglon%>';
<%
		}

	//}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&id=<%=id%>&renglon=<%=renglon%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>';
}
</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
