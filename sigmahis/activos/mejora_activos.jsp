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
<!-- Pantalla: "Mejoras de Activos"              -->
<!-- Página para Registrar las Mejoras Realizadas a los Activos  -->
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 27/10/2010                           -->
<!-- Desarrollado por: José A. Acevedo C.        -->
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al  = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo2 = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
String cuentaCode = request.getParameter("cuentaCode");
String bancoCode = request.getParameter("bancoCode");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio      = cDateTime.substring(6,10);
String secuencia = request.getParameter("secuencia");

String usuarioCreacion     = "";
String usuarioModificacion = "";
String fechaCreacion      = "";
String fechaModificacion  = "";
String msg = " ";
boolean viewMode = false;

String numMejora  = request.getParameter("numMejora");
String tipoSalida = "", beneficiario = "";  

if (mode == null) mode = "add";

if(mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))    
{

 sql = "select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, a.cuentah_detalle, a.estatus, a.tipo_activo, a.cod_provee, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placaVal, a.ue_codigo, a.nivel_codigo_ubic, c.descripcion unidad_desc, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo, a.npoliza, a.cond_fisica, a.placa, a.placa_nueva,  to_char(a.fecha_crea,'dd/mm/yyyy') fecha_crea, a.factura, to_char(a.final_garantia,'dd/mm/yyyy') final_garantia, a.vida_estimada, a.tipo_de_depre, a.estatus, a.valor__mejor_acum, a.valor_inicial, a.meses_depre_act, a.acum_deprem, a.valor_deprem, a.valor_depre_mejora, a.acum_deprec, a.valor_mejora_actual, a.valor_actual, a.valor_rescate, (nvl(a.valor_actual,0) + nvl(a.valor_mejora_actual,0)) valor_total, a.usua_crea, h.descripcion clasif_desc, b.descripcion cuentah_desc, b.cod_clasif, u.descripcion ubicacion_desc, t.descripcion entrada_desc, p.nombre_proveedor proveedor_desc, to_char(m.fecha_transaccion,'dd/mm/yyyy') fechaTransaccion, nvl(m.explicacion_mejora, ' ') explicacionMejora, nvl(m.valor, 0) valorMejora from tbl_con_activos a, tbl_con_detalle b, tbl_sec_unidad_ejec c, tbl_con_clasif_hacienda h, tbl_com_proveedor p, tbl_con_tipo_entrada t, tbl_con_ubic_fisica u,tbl_con_mejora m where a.compania="+(String)session.getAttribute("_companyId")+" and a.cuentah_activo = b.cod_espec(+) and a.cuentah_espec = b.codigo_subesp(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = b.cod_compania(+) and a.compania = c.compania and a.ue_codigo = c.codigo and a.cod_clasif = h.cod_clasif(+) and a.entrada_codigo = t.codigo_entrada(+) and a.cod_provee = p.cod_provedor(+) and a.compania = p.compania(+) and a.nivel_codigo_ubic = u.codigo_ubic(+) and a.secuencia = '"+secuencia+"' and a.secuencia = m.act_secuen(+) and a.compania = m.compania(+) order by a.secuencia";
    cdo = SQLMgr.getData(sql);
	
	//if(cdo.getColValue("estatus").equalsIgnoreCase("RETIR")) viewMode = true;
	
	if (mode.equalsIgnoreCase("add"))
		{
			 numMejora = "0";	
			 fechaCreacion     = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
			 fechaModificacion = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
			 usuarioCreacion = UserDet.getUserName();
			 cdo.addColValue("fechaCrea",CmnMgr.getCurrentDate("dd/mm/yyyy"));
			 cdo.getColValue("fecha_crea");			
			 cdo.getColValue("fecha_entrada");		  
	
		if (secuencia == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");
		
	   }
    
    fechaModificacion = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
    usuarioModificacion = UserDet.getUserName(); 	

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

function doAction()
{} 


</script>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Activo Fijo - Mejoras - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Activo Fijo - Registrar Mejoras - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - MEJORAS DE ACTIVOS FIJOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">   
<tr>
  <td class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<!--GENERALES TAB0-->
<div class="dhtmlgoodies_aTab">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center"> 
<% fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("usuarioCreacion",usuarioCreacion)%>
<%=fb.hidden("usuarioModificacion",usuarioModificacion)%>
<%=fb.hidden("fechaCreacion",fechaCreacion)%>
<%=fb.hidden("fechaModificacion",fechaModificacion)%>
<%=fb.hidden("usua_crea",cdo.getColValue("usua_crea"))%>
<%=fb.hidden("cuentah_detalle",cdo.getColValue("cuentah_detalle"))%>
<%=fb.hidden("cargo_uso","N")%>
<%=fb.hidden("cod_articulo",cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("cod_clase",cdo.getColValue("cod_clase"))%>
<%=fb.hidden("cod_flia",cdo.getColValue("cod_flia"))%>
<%=fb.hidden("porcentaje",cdo.getColValue("porcentaje"))%>
<%=fb.hidden("placa",cdo.getColValue("placa"))%>
<%=fb.hidden("placa_nueva",cdo.getColValue("placa_nueva"))%>
<%=fb.hidden("numMejora",numMejora)%>

  <tr> 
    <td>
      <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
        <tr>
          <td id="TPrincipal" align="left" width="100%" onClick="javascript:showHide(0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr class="TextPanel">
                <td width="97%" >&nbsp;Activos - Mejoras </td>
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
                <td width="15%">Fecha de Creación :</td>
                <td width="37%"> <%=fb.textBox("fecha_crea",cdo.getColValue("fecha_crea"),true,false,true,15)%></td>
                 <td width="18%" align="center"> Placa : &nbsp; <%=fb.textBox("secuencia",secuencia,true,false,true,10)%></td>
                <td width="30%" align="center"> Fecha de Entrada <%=fb.textBox("fecha_entrada",cdo.getColValue("fecha_entrada"),true,false,true,15)%></td>      
              </tr>             
              <tr class="TextRow02">        
                <td>Listado de Activo</td>
                <td colspan="3">
								<%=fb.textBox("cuentah_activo",cdo.getColValue("cuentah_activo"),false,false,true,7)%>
                <%=fb.textBox("cuentah_espec",cdo.getColValue("cuentah_espec"),false,false,true,7)%>
								<%=fb.textBox("cuentah_detalle",cdo.getColValue("cuentah_detalle"),false,false,true,7)%>
								<%=fb.textBox("cuentah_desc",cdo.getColValue("cuentah_desc"),false,false,true,55)%>
                <!--%=fb.button("btnlistado","...",false,false,null,null,"onClick=\"javascript:getListadoActivo()\"")%-->
				</td>
              </tr>
              
			  <tr class="TextRow02">        
                <td>Clasificación</td>
                <td colspan="3"><%=fb.textBox("cod_clasif",cdo.getColValue("cod_clasif"),false,false,true,7)%>
								<%=fb.textBox("clasif_desc",cdo.getColValue("clasif_desc"),false,false,true,70)%></td>
              </tr>
              
			  <tr class="TextHeader02">        
                <td colspan="4">Ubicación del Activo</td>
			  </tr>	
								
				<tr class="TextRow02">
				  <td> Unidad Administrativa : </td>
				  <td colspan="3">
								<%=fb.textBox("ue_codigo",cdo.getColValue("ue_codigo"),false,false,true,7)%>
                <%=fb.textBox("unidad_desc",cdo.getColValue("unidad_desc"),false,false,true,60)%>
                  </td>
              </tr>
				
				<tr class="TextRow02">
				  <td> Ubicación Física : </td>
				 	<td colspan="3">
						<%=fb.textBox("nivel_codigo_ubic",cdo.getColValue("nivel_codigo_ubic"),false,false,true,7)%>
                <%=fb.textBox("ubicacion_desc",cdo.getColValue("ubicacion_desc"),false,false,true,60)%>
                   </td>
              </tr>
		
							
				<!--tr class="TextRow01">
                 <td colspan="4">Valores del Activo</td>               
               </tr-->
			   
               <!--tr class="TextRow02">
                  <td>Valor Inicial del Activo:</td>
                  <td><%=fb.decBox("valor_inicial",cdo.getColValue("valor_inicial"),false,false,true,15,12.2,null,null,"onChange=\"javascript:getDepreciacion()\"")%> </td>				  
				   <td>Depreciación Acumulada: </td>
                  <td><%=fb.decBox("acum_deprec",cdo.getColValue("acum_deprec"),false, false, true,15,12.2,null,null,"","",false,"")%></td>				         
               </tr-->
			   
			   <!--tr class="TextRow02">
                   <td>Valor Actual del Activo: </td>
                   <td><%=fb.decBox("valor_actual",cdo.getColValue("valor_actual"),false, false, true,15,12.2,null,null,"","",false,"")%></td>		 
				  <td>Mejoras Aplicada : &nbsp;</td>
                  <td><%=fb.decBox("valor__mejor_acum",cdo.getColValue("valor__mejor_acum"),false, false, true,15,12.2,null,null,"","",false,"")%></td> 
               </tr-->
							
			  <tr class="TextHeader02"> 
			    <td colspan="4">Información de la Mejora al Activo</td>
			  </tr>
			 
			 <tr class="TextRow02"> 
			  <td>Fecha de la Transacci&oacute;n : &nbsp;</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_sal" />
                  <jsp:param name="valueOfTBox1" value="<%=(viewMode)?cdo.getColValue("fecha_sal"):cDateTime%>"/>
                  </jsp:include>
				 </td> 
				 <td>Año: &nbsp;<%=fb.textBox("anio",anio,false,false,true,7)%></td>				 
				 <td>No. Mejora: &nbsp;&nbsp;<%=numMejora%></td>	
			  </tr>
			  
			  <!--tr class="TextRow02">
			    <td>Tipo de Salida:</td>
				<td><%=fb.select(ConMgr.getConnection(),"select  tiposal.cod_salida, tiposal.descripcion||' - '||tiposal.cod_salida  descTipoSal from tbl_con_tipo_salida tiposal order by 2","tiposal",cdo.getColValue("tiposal"),"")%></td>
				<td>Beneficiario:</td>
				<td>&nbsp;<%=fb.textBox("beneficiario",cdo.getColValue("beneficiario"),false,false,viewMode,60,50)%></td>
			  </tr-->
			  
			  <tr class="TextRow02">
                 <td>Valor de la Mejora Aplicada: </td>
                 <td colspan="3"><%=fb.decBox("valorMejora",cdo.getColValue("valorMejora"),false, false,viewMode,15,12.2,null,null,"","",false,"")%></td>				  
               </tr>
						
			 <tr class="TextRow02">
		        <td>Explicación</td>
	            <td colspan="3"><%=fb.textarea("explicacionMejora",cdo.getColValue("explicacionMejora"),true,false,viewMode,55,2,2000,null,"",null)%></td>   
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
	  <%=fb.submit("save","Guardar",true,viewMode)%>
	  <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>	  
	  </td>
  </tr>
  <tr>
      <td colspan="2">&nbsp;</td>
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
  numMejora = request.getParameter("numMejora"); 
 
  cdo = new CommonDataObject(); 

  // System.out.println(">>>>>>>>>>>:1"+request.getParameter("numDocSal"));
  cdo.setTableName("tbl_con_mejora"); 
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));    
  cdo.addColValue("act_secuen",request.getParameter("secuencia")); 
  cdo.addColValue("n_mejora",request.getParameter("numMejora"));  
  cdo.addColValue("fecha_transaccion",request.getParameter("fecha_sal"));  
  cdo.addColValue("ano",request.getParameter("anio")); 
  cdo.addColValue("valor",request.getParameter("valorMejora"));  
  cdo.addColValue("explicacion_mejora",request.getParameter("explicacionMejora"));     
 
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {     
    // cdo.addColValue("usu_crea",request.getParameter("usuarioCreacion"));
	// cdo.addColValue("fecha_crea",request.getParameter("fechaCreacion"));	

	 cdo.setAutoIncCol("n_mejora");	 
	 cdo.addPkColValue("n_mejora","");	 
     SQLMgr.insert(cdo);	
  }
  else
  {
     cdo.setWhereClause("act_secuen='"+request.getParameter("secuencia")+"' and compania="+(String) session.getAttribute("_companyId"));
 
    
     SQLMgr.update(cdo);
  }
  ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
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
