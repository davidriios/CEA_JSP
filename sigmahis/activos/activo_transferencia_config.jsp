<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String numDoc = request.getParameter("numDoc");
String unidad = request.getParameter("unidad");

String secuencia = request.getParameter("secuencia");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";
boolean viewMode = false;

if(mode.equals("edit")) viewMode = true;

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (mode.equalsIgnoreCase("add"))
  {
    fechaCrea = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userCrea = UserDet.getUserName();
    cdo.addColValue("fechaCrea",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		 cdo.addColValue("fecha_crea",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		 cdo.addColValue("fecha_modif",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		 cdo.addColValue("final_garantia","");
		 cdo.addColValue("valor_inicial","0");
		 cdo.addColValue("valor__mejor_acum","0");
		 cdo.addColValue("meses_depre_act","0");
		 cdo.addColValue("acum_deprem","0");
		 cdo.addColValue("valor_deprem","0");
		 cdo.addColValue("valor_depre_mejora","0");
		 cdo.addColValue("acum_deprec","0");
		 cdo.addColValue("valor_mejora_actual","0");
		 cdo.addColValue("valor_actual","0");
		 cdo.addColValue("valor_rescate","0");
		 cdo.addColValue("valor_total","0");
		 
		secuencia = " ";	
    
  }
  else
  {
    if (secuencia == null) throw new Exception("Activo no es válido. Por favor intente nuevamente!");
        
    
    fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
    userMod = UserDet.getUserName();
		
		
		 sql = "select a.num_doc, a.unid_remitente codigo, to_char(a.fecha_transaccion,'dd/mm/yyyy') fecha_crea, a.ano anio, a.unid_destino unidadCode, c.descripcion , d.descripcion unidad, a.tipo_unidad_recep tipo_unidad, a.tipo_transf tipo, to_char(a.fecha_envio,'dd/mm/yyyy') fecha_envio, to_char(a.fecha_finalizacion,'dd/mm/yyyy') fecha_final, to_char(a.fecha_recepcion,'dd/mm/yyyy') fecha_recepcion, a.empresa, a.observacion from tbl_con_transferencia a, tbl_con_detalle_transfs b, tbl_sec_unidad_ejec c, tbl_sec_unidad_ejec d where a.compania="+(String)session.getAttribute("_companyId")+" and a.num_doc = "+numDoc+" and a.unid_remitente ="+unidad+" and a.compania = c.compania(+) and a.unid_remitente = c.codigo(+) and a.compania = d.compania(+) and a.unid_destino = d.codigo(+) and a.unid_remitente = b.tras_uremit(+) and a.num_doc = b.tras_num(+) and a.compania = b.tras_compania(+)";
     
     cdo = SQLMgr.getData(sql);
  }
%>
<html>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script> 
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function getListadoActivo()
{
	abrir_ventana('../common/search_codificador_activo.jsp?fp=activo');            
}
function getListadoUnidad()
{
	abrir_ventana('../common/search_depto.jsp?fp=activo');            
}
function getListadoUbicacion()
{
	abrir_ventana('../common/search_depto.jsp?fp=fisica');            
}
function getListadoEntrada()
{
	abrir_ventana('../common/search_depto.jsp?fp=entrada');            
}
function getListadoProveedor()
{
	abrir_ventana('../common/search_proveedor.jsp?fp=activo');            
}
function getCuentaBanco()
{
	abrir_ventana('../activos/ctabancaria_banco_list.jsp');            
}
function getCatalogo()
{
	abrir_ventana('../activos/ctabancaria_catalogo_list.jsp?id=1');            
}
function getDepreciacion()
{
var inicial = document.form1.valor_inicial.value;
var vidaEst = document.form1.vida_estimada.value;
var porcentaje = "";
var deprec = "";
if(vidaEst==0 || vidaEst == null) alert('Vida Estimada sin registro...Verifique...');
porcentaje = 100 / vidaEst;
deprec = (((inicial * porcentaje) / 100) /12);

document.form1.valor_deprem.value = deprec.toFixed(2);
}
function getDepreAcum()
{
var inicial = parseFloat(document.form1.valor_inicial.value);
var meses = document.form1.meses_depre_act.value;
var vidaEst = document.form1.vida_estimada.value * 12;
var deprem = document.form1.valor_deprem.value;
var deprec = "";
var valor = "";

if(vidaEst==0 || meses == null) alert('Vida Estimada / Meses Depreciados sin registro...Verifique...');

if(meses > vidaEst) alert('Los meses son mayores a la vida estimada, VERIFIQUE!');
else {

deprec = (meses * deprem);
document.form1.acum_deprec.value = deprec.toFixed(2);
if((inicial - deprec) < 1.00 ) {
document.form1.valor_actual.value = 1;
document.form1.valor_total.value = 1;
} else {
valor = (inicial - deprec);
document.form1.valor_actual.value = valor.toFixed(2);
}
if (meses==null) document.form1.meses_depre_act.value=0;
}
}
function getMejora()
{
var actual = parseFloat(document.form1.valor_actual.value);
var mejora = parseFloat(document.form1.valor_mejora_actual.value);
var porcentaje = "";
var deprec = "";
var valor = "";
if(actual==0) alert('Valor Actual sin registro...Verifique...');
if(mejora!=null) mejora = document.form1.valor_mejora_actual.value;
 mejora = parseFloat(document.form1.valor_mejora_actual.value);
valor = actual+mejora;
document.form1.valor_total.value = valor.toFixed(2);

}

</script>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Transferencia de Activo Fijo Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Transferencia de Activo Fijo Edición - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - TRANSACCION - ACTIVO FIJO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">   
<tr>
  <td class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<!--GENERALES TAB0-->
<div class="dhtmlgoodies_aTab">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center"> 

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("userCrea",userCrea)%>
<%=fb.hidden("userMod",userMod)%>
<%=fb.hidden("fechaCrea",fechaCrea)%>
<%=fb.hidden("fechaMod",fechaMod)%>
<%=fb.hidden("usua_crea",cdo.getColValue("usua_crea"))%>
<%=fb.hidden("cuentah_detalle",cdo.getColValue("cuentah_detalle"))%>
<%=fb.hidden("cargo_uso","N")%>
<%=fb.hidden("cod_articulo",cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("cod_clase",cdo.getColValue("cod_clase"))%>
<%=fb.hidden("cod_flia",cdo.getColValue("cod_flia"))%>
<%=fb.hidden("porcentaje",cdo.getColValue("porcentaje"))%>
<%=fb.hidden("placa",cdo.getColValue("placa"))%>
<%=fb.hidden("placa_nueva",cdo.getColValue("placa_nueva"))%>

  <tr> 
    <td>
      <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
        <tr>
          <td id="TPrincipal" align="left" width="100%" onClick="javascript:showHide(0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr class="TextPanel">
                <td width="97%" >&nbsp;Transferencia de Activos</td>
                <td width="3%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
              </tr>
            </table>    
          </td>
        </tr> 
        <tr>
          <td>  
          <div id="panel0" style="visibility:visible;">
            <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						
						<tr class="TextRow02">
                <td width="10%">Fecha :</td>
                <td width="10%" align="left"> <%=fb.textBox("fecha_crea",cdo.getColValue("fecha_crea"),true,false,true,15)%></td>
								<td width="10%"> &nbsp; Año: &nbsp;</td>
								 <td width="10%"> <%=fb.textBox("anio",cdo.getColValue("anio"),true,false,viewMode,8)%> </td>
								 <td width="10%" align="center"> &nbsp; No. Documento</td>
               	 <td width="20%" align="left"><%=fb.textBox("num_doc",cdo.getColValue("num_doc"),true,false,true,10)%></td>
								  <td width="10%" align="center">&nbsp;</td>
               	 <td width="20%"> &nbsp;</td>
              </tr> 
							
							<tr class="TextRow01">        
                <td colspan="5" align="left" > &nbsp; &nbsp;UNIDAD REMITENTE</td>
								 <td colspan="3" align="center" > &nbsp; &nbsp;UNIDAD DESTINO</td>
							</tr>	
							
							<tr class="TextRow02">
							  <td colspan="5">
								<%=fb.textBox("codigo",cdo.getColValue("codigo"),false,false,true,7)%>
                <%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,60)%>
                <%=fb.button("btnunidad","...",false,false,null,null,"onClick=\"javascript:getRemitente()\"")%></td>
              		<td colspan="3">
								<%=fb.textBox("unidadCode",cdo.getColValue("unidadCode"),false,false,true,7)%>
                <%=fb.textBox("unidad",cdo.getColValue("unidad"),false,false,false,60)%>
                <%=fb.button("btnunidad","...",false,false,null,null,"onClick=\"javascript:getDestino()\"")%></td>
						  </tr>
							
							<tr class="TextRow01">        
                <td colspan="8" align="left" > &nbsp; &nbsp;INFORMACION DE LA TRANSFERENCIA </td>
							</tr>	
							
						<tr class="TextRow02">
                <td colspan="3" align="center"> Ubicación Unidad Destino</td>
								<td colspan="3" align="center"> Tipo de Transferencia</td>
								<td colspan="2" align="left"> Empresa</td>
            </tr>
						
						<tr class="TextRow02">
                <td colspan="3" align="center"> <%=fb.select("tipo_unidad","E=UBICACION EXTERNA,I=UBICACION INTERNA",cdo.getColValue("tipo_unidad"))%></td>
								<td colspan="3" align="center"> <%=fb.select("tipo","DEFINI=PERMANENTE,TEMP=TEMPORAL",cdo.getColValue("tipo"))%></td>
								<td colspan="2" align="left">  <%=fb.textBox("empresa",cdo.getColValue("empresa"),true,false,true,45)%></td>
            </tr>
							
						
            <tr class="TextRow02">
                <td colspan="3" align="center">Fecha Envio : &nbsp;
							    <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_envio" />
                  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_envio")%>" />
                  </jsp:include>
							 </td> 
							  <td colspan="3" align="right">Fecha Recepción : &nbsp;
							    <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_recepcion" />
                  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_recepcion")%>" />
                  </jsp:include>
							 </td>  
            	  <td colspan="2" align="right">Fecha Finalización : &nbsp;
							    <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_final" />
                  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_final")%>" />
                  </jsp:include>
							 </td>       
            </tr>  
							
						<tr class="TextRow02">
                 <td colspan="8">Observaci&oacute;n : &nbsp;<%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,60,4,2000,"","width:100%","")%></td>
						</tr>
					    	
            </table>
          </div>
          </td>
        </tr>
      </table>      
    </td>
  </tr>             
 
 
  <tr class="TextRow02">
      <td align="right">
	  Opciones de Guardar: 
	  <%=fb.radio("saveOption","N")%>Crear Otro 
	  <%=fb.radio("saveOption","O")%>Mantener Abierto 
	  <%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
	  <%=fb.submit("save","Guardar",true,false)%>
	  <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
	  </td>
  </tr>
  <tr>
      <td colspan="8">&nbsp;</td>
  </tr>
<%=fb.formEnd(true)%> 
</table>

</div>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->


  </td>
</tr>
</table>    

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  secuencia = request.getParameter("secuencia"); 
 
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_activos"); 
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));  
	cdo.addColValue("secuencia",request.getParameter("secuencia"));  
  cdo.addColValue("fecha_de_entrada",request.getParameter("fecha_entrada")); 
  cdo.addColValue("estatus",request.getParameter("estatus"));
  cdo.addColValue("tipo_activo",request.getParameter("tipo_activo")); 
  cdo.addColValue("tipo_de_depre",request.getParameter("tipo_de_depre"));
  cdo.addColValue("valor_deprem",request.getParameter("valor_deprem")); 
  cdo.addColValue("valor_inicial",request.getParameter("valor_inicial"));
  cdo.addColValue("valor_rescate",request.getParameter("valor_rescate")); 
  cdo.addColValue("valor_actual",request.getParameter("valor_actual")); 
	cdo.addColValue("usua_crea",request.getParameter("usua_crea")); 
  cdo.addColValue("fecha_crea",request.getParameter("fecha_crea"));
	cdo.addColValue("cargo_uso",request.getParameter("cargo_uso"));  
	if (request.getParameter("ue_codigo") != null && !request.getParameter("ue_codigo").trim().equals("")) cdo.addColValue("ue_codigo",request.getParameter("ue_codigo")); 
  if (request.getParameter("entrada_codigo") != null && !request.getParameter("entrada_codigo").trim().equals("")) cdo.addColValue("entrada_codigo",request.getParameter("entrada_codigo")); 
	if (request.getParameter("cuentah_activo") != null && !request.getParameter("cuentah_activo").trim().equals("")) cdo.addColValue("cuentah_activo",request.getParameter("cuentah_activo"));
  if (request.getParameter("cuentah_espec") != null && !request.getParameter("cuentah_espec").trim().equals("")) cdo.addColValue("cuentah_espec",request.getParameter("cuentah_espec")); 
  if (request.getParameter("cuentah_detalle") != null && !request.getParameter("cuentah_detalle").trim().equals("")) cdo.addColValue("cuentah_detalle",request.getParameter("cuentah_detalle"));
  if (request.getParameter("nivel_codigo_ubic") != null && !request.getParameter("nivel_codigo_ubic").trim().equals("")) cdo.addColValue("nivel_codigo_ubic",request.getParameter("nivel_codigo_ubic"));
	if (request.getParameter("orden__compra") != null && !request.getParameter("orden__compra").trim().equals("")) cdo.addColValue("orden__compra",request.getParameter("orden__compra")); 
  if (request.getParameter("acum_deprec") != null && !request.getParameter("acum_deprec").trim().equals("")) cdo.addColValue("acum_deprec",request.getParameter("acum_deprec")); 
  if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals("")) cdo.addColValue("factura",request.getParameter("factura"));
  if (request.getParameter("valor__mejor_acum") != null && !request.getParameter("valor__mejor_acum").trim().equals("")) cdo.addColValue("valor__mejor_acum",request.getParameter("valor__mejor_acum")); 
  if (request.getParameter("valor_mejora_actual") != null && !request.getParameter("valor_mejora_actual").trim().equals("")) cdo.addColValue("valor_mejora_actual",request.getParameter("valor_mejora_actual"));
	if (request.getParameter("valor_depre_mejora") != null && !request.getParameter("valor_depre_mejora").trim().equals("")) cdo.addColValue("valor_depre_mejora",request.getParameter("valor_depre_mejora")); 
  if (request.getParameter("acum_deprem") != null && !request.getParameter("acum_deprem").trim().equals("")) cdo.addColValue("acum_deprem",request.getParameter("acum_deprem")); 
  if (request.getParameter("meses_depre_act") != null && !request.getParameter("meses_depre_act").trim().equals("")) cdo.addColValue("meses_depre_act",request.getParameter("meses_depre_act"));
  if (request.getParameter("cod_provee") != null && !request.getParameter("cod_provee").trim().equals("")) cdo.addColValue("cod_provee",request.getParameter("cod_provee")); 
  if (request.getParameter("observacion") != null && !request.getParameter("observacion").trim().equals("")) cdo.addColValue("observacion",request.getParameter("observacion"));
	if (request.getParameter("vida_estimada") != null && !request.getParameter("vida_estimada").trim().equals("")) cdo.addColValue("vida_estimada",request.getParameter("vida_estimada")); 
  if (request.getParameter("final_garantia") != null && !request.getParameter("final_garantia").trim().equals("")) cdo.addColValue("final_garantia",request.getParameter("final_garantia"));
  if (request.getParameter("cond_fisica") != null && !request.getParameter("cond_fisica").trim().equals("")) cdo.addColValue("cond_fisica",request.getParameter("cond_fisica")); 
  if (request.getParameter("cod_clasif") != null && !request.getParameter("cod_clasif").trim().equals("")) cdo.addColValue("cod_clasif",request.getParameter("cod_clasif"));
	if (request.getParameter("npoliza") != null && !request.getParameter("npoliza").trim().equals("")) cdo.addColValue("npoliza",request.getParameter("npoliza"));
	//if (!request.getParameter("precio_venta").trim().equals("")) cdo.addColValue("precio_venta",request.getParameter("precio_venta"));
  //if (!request.getParameter("tipo_servicio").trim().equals("")) cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio")); 
 // if (!request.getParameter("tipo_precio").trim().equals("")) cdo.addColValue("tipo_precio",request.getParameter("tipo_precio"));
	if (request.getParameter("cod_articulo") != null && !request.getParameter("cod_articulo").trim().equals("")) cdo.addColValue("cod_articulo",request.getParameter("cod_articulo"));
  if (request.getParameter("cod_clase") != null && !request.getParameter("cod_clase").trim().equals("")) cdo.addColValue("cod_clase",request.getParameter("cod_clase"));
	if (request.getParameter("cod_flia") != null && !request.getParameter("cod_flia").trim().equals("")) cdo.addColValue("cod_flia",request.getParameter("cod_flia"));
  if (request.getParameter("porcentaje") != null && !request.getParameter("porcentaje").trim().equals("")) cdo.addColValue("porcentaje",request.getParameter("porcentaje")); 
  if (request.getParameter("placa") != null && !request.getParameter("placa").trim().equals("")) cdo.addColValue("placa",request.getParameter("placa"));
	//if (!request.getParameter("bandera").trim().equals("")) cdo.addColValue("bandera",request.getParameter("bandera"));
	if (request.getParameter("placa_nueva") != null && !request.getParameter("placa_nueva").trim().equals("")) cdo.addColValue("placa_nueva",request.getParameter("placa_nueva"));

  cdo.addColValue("usua_mod",request.getParameter("userMod")); 
  cdo.addColValue("fecha_mod",request.getParameter("fechaMod"));    
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {     
     cdo.addColValue("usua_crea",request.getParameter("userCrea"));
		 cdo.addColValue("fecha_crea",request.getParameter("fechaCrea"));
		// cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		// cdo.setAutoIncCol("secuencia");
		 
		 cdo.addPkColValue("secuencia","");
		 
     SQLMgr.insert(cdo);
		 secuencia = SQLMgr.getPkColValue("secuencia");
  }
  else
  {
     cdo.setWhereClause("secuencia='"+request.getParameter("secuencia")+"' and compania="+(String) session.getAttribute("_companyId"));

     SQLMgr.update(cdo);
  }
  ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../build/web/js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/activos/list_activos_fijos.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/activos/list_activos_fijos.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/activos/list_activos_fijos.jsp';
<%
	}
	
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&secuencia=<%=secuencia%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>