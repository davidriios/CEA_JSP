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

ArrayList al  = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo2 = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
String cuentaCode = request.getParameter("cuentaCode");
String bancoCode = request.getParameter("bancoCode");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String anio      = cDateTime.substring(6,10);
String secuencia = request.getParameter("secuencia");
String secActivo = request.getParameter("secActivo");
String fechaEntrada = request.getParameter("fecha_entrada");
String usuarioCreacion     = "";
String usuarioModificacion = UserDet.getUserName();
String fechaCreacion      = "";
String fechaModificacion  = "";
String msg = " ";
boolean viewMode = false;
String color = "TextRow01";

String numDocSalida = request.getParameter("numDocSalida");
String tipoSalida = "", beneficiario = "";

if (mode == null) mode = "add";
if (numDocSalida == null)  numDocSalida = "0";

if(mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{

 sql = "select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, a.cuentah_detalle, a.estatus, a.tipo_activo, a.cod_provee, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placaVal, a.ue_codigo, a.nivel_codigo_ubic, c.descripcion unidad_desc, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo, a.npoliza, a.cond_fisica, a.placa, a.placa_nueva,  to_char(a.fecha_crea,'dd/mm/yyyy') fecha_crea, a.factura, to_char(a.final_garantia,'dd/mm/yyyy') final_garantia, a.vida_estimada, a.tipo_de_depre, a.estatus, a.valor__mejor_acum, a.valor_inicial, a.meses_depre_act, a.acum_deprem, a.valor_deprem, a.valor_depre_mejora, a.acum_deprec, a.valor_mejora_actual, a.valor_actual, a.valor_rescate, (nvl(a.valor_actual,0) + nvl(a.valor_mejora_actual,0)) valor_total, a.usua_crea, h.descripcion clasif_desc, es.descripcion cuentah_desc, a.cod_clasif, u.descripcion ubicacion_desc, t.descripcion entrada_desc, p.nombre_proveedor proveedor_desc, to_char(sa.fecha_sal,'dd/mm/yyyy') fecha_sal,nvl(sa.explicacion_salida, ' ') explicacion, nvl(sa.beneficiario, ' ') beneficiario, nvl(sa.valor_venta, 0) valor_venta, nvl(to_char(sa.tiposal), ' ') tiposal,sa.ano from tbl_con_activos a, tbl_con_detalle b, tbl_sec_unidad_ejec c, tbl_con_clasif_hacienda h, tbl_com_proveedor p, tbl_con_tipo_entrada t, tbl_con_ubic_fisica u, tbl_con_salida_activos sa ,tbl_con_especificacion es where a.compania="+(String)session.getAttribute("_companyId")+" and a.cuentah_activo = b.cod_espec(+) and a.cuentah_espec = b.codigo_subesp(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = b.cod_compania(+) and a.compania = c.compania and a.ue_codigo = c.codigo and a.cod_clasif = h.cod_clasif(+) and a.entrada_codigo = t.codigo_entrada(+) and a.cod_provee = p.cod_provedor(+) and a.compania = p.compania(+) and a.nivel_codigo_ubic = u.codigo_ubic(+) and a.secuencia = '"+secuencia+"' and a.secuencia = sa.sec_activo(+) and a.compania = sa.compania(+) and a.cuentah_activo = es.cta_control and a.cuentah_espec = es.codigo_espec and a.compania = es.compania order by a.secuencia";
    cdo = SQLMgr.getData(sql);
    
    if (cdo == null){
        cdo = new CommonDataObject();
	
    }

	if(cdo.getColValue("estatus"," ").equalsIgnoreCase("RETIR")) viewMode = true;

	if (mode.equalsIgnoreCase("add"))
		{
			
			 //fechaCreacion     = cDateTime;
			 //fechaModificacion = cDateTime;
			 //usuarioCreacion = UserDet.getUserName();
			 cdo.addColValue("ano",anio);
			 //cdo.addColValue("fecha_crea", cDateTime.substring(0,10));
			 //cdo.addColValue("fecha_entrada", cDateTime.substring(0,10));


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
{
 <%if (viewMode==true){%> alert('ADVERTENCIA: A este ACTIVO ya se le tramitó la SALIDA');
  <%}%>
}


</script>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Activo Fijo - Registrar Salida - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Activo Fijo - Registrar Salida - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - SALIDAS DE ACTIVOS FIJOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<!--GENERALES TAB0-->
<div class="dhtmlgoodies_aTab">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("usua_crea",cdo.getColValue("usua_crea"))%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("cuentah_detalle",cdo.getColValue("cuentah_detalle"))%>
<%=fb.hidden("cargo_uso","N")%>
<%=fb.hidden("cod_articulo",cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("cod_clase",cdo.getColValue("cod_clase"))%>
<%=fb.hidden("cod_flia",cdo.getColValue("cod_flia"))%>
<%=fb.hidden("porcentaje",cdo.getColValue("porcentaje"))%>
<%=fb.hidden("placa_nueva",cdo.getColValue("placa_nueva"))%>
<%=fb.hidden("numDocSalida",numDocSalida)%>

  <tr>
    <td>
      <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
        <tr>
          <td id="TPrincipal" align="left" width="100%" onClick="javascript:showHide(0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr class="TextPanel">
                <td width="97%" >&nbsp;Activos - Salida </td>
                <td width="3%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td>
          <div id="panel0" style="visibility:visible;">
            <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
              <tr class="<%=color%>">
                <td width="20%">Fecha de Creación :</td>
                <td width="32%"> <%=fb.textBox("fecha_crea",cdo.getColValue("fecha_crea"),true,false,true,15)%></td>
                 <td width="18%" align="center"> Placa : &nbsp; <%=fb.textBox("placa",cdo.getColValue("placa"),true,false,true,10)%></td>
                <td width="30%" align="center"> Fecha de Entrada <%=fb.textBox("fecha_entrada",cdo.getColValue("fecha_entrada"),true,false,true,15)%></td>
              </tr>
              <tr class="<%=color%>">
                <td>Listado de Activo</td>
                <td colspan="3">
								<%=fb.textBox("cuentah_activo",cdo.getColValue("cuentah_activo"),false,false,true,7)%>
                <%=fb.textBox("cuentah_espec",cdo.getColValue("cuentah_espec"),false,false,true,7)%>
								<%=fb.textBox("cuentah_detalle",cdo.getColValue("cuentah_detalle"),false,false,true,7)%>
								<%=fb.textBox("cuentah_desc",cdo.getColValue("cuentah_desc"),false,false,true,55)%>
                <!--%=fb.button("btnlistado","...",false,false,null,null,"onClick=\"javascript:getListadoActivo()\"")%-->
				</td>
              </tr>

			  <tr class="<%=color%>">
                <td>Clasificación</td>
                <td colspan="3"><%=fb.textBox("cod_clasif",cdo.getColValue("cod_clasif"),false,false,true,7)%>
								<%=fb.textBox("clasif_desc",cdo.getColValue("clasif_desc"),false,false,true,70)%></td>
              </tr>
			  <tr class="<%=color%>">
                 <td>Nombre: &nbsp;</td>
				 <td colspan="3"><%=fb.textBox("observacion",cdo.getColValue("observacion"),true,true,false,100,200,"","","")%></td>
				 
               </tr>
			  <tr class="TextHeader02">

                <td colspan="4">Ubicación del Activo</td>
			  </tr>

				<tr class="<%=color%>">
				  <td> Unidad Administrativa : </td>
				  <td colspan="3">
								<%=fb.textBox("ue_codigo",cdo.getColValue("ue_codigo"),false,false,true,7)%>
                <%=fb.textBox("unidad_desc",cdo.getColValue("unidad_desc"),false,false,true,60)%>
                  </td>
              </tr>

				<tr class="<%=color%>">
				  <td> Ubicación Física : </td>
				 	<td colspan="3">
						<%=fb.textBox("nivel_codigo_ubic",cdo.getColValue("nivel_codigo_ubic"),false,false,true,7)%>
                <%=fb.textBox("ubicacion_desc",cdo.getColValue("ubicacion_desc"),false,false,true,60)%>
                   </td>
              </tr>


				<tr class="TextHeader02">
                 <td colspan="4">Valores del Activo</td>

               </tr>

               <tr class="<%=color%>">
                  <td>Valor Inicial del Activo:</td>
                  <td><%=fb.decBox("valor_inicial",cdo.getColValue("valor_inicial"),false,false,true,15,12.2,null,null,"onChange=\"javascript:getDepreciacion()\"")%> </td>
				   				<td>Depreciación Acumulada: </td>
                  <td><%=fb.decBox("acum_deprec",cdo.getColValue("acum_deprec"),false, false, true,15,12.2,null,null,"","",false,"")%></td>
               </tr>

			   			<tr class="<%=color%>">
                   <td>Valor Actual del Activo: </td>
                   <td><%=fb.decBox("valor_actual",cdo.getColValue("valor_actual"),false, false, true,15,12.2,null,null,"","",false,"")%></td>
				  				<td>Mejoras Aplicada : &nbsp;</td>
                  <td><%=fb.decBox("valor__mejor_acum",cdo.getColValue("valor__mejor_acum"),false, false, true,15,12.2,null,null,"","",false,"")%></td>
              </tr>

						  <tr class="TextHeader02">
						    <td colspan="4">Información de la Salida</td>
						  </tr>

						 <tr class="<%=color%>">
						  <td>Fecha de Salida : &nbsp;</td>
							<td><jsp:include page="../common/calendar.jsp" flush="true">
			                  <jsp:param name="noOfDateTBox" value="1" />
			                  <jsp:param name="nameOfTBox1" value="fecha_sal" />
			                  <jsp:param name="valueOfTBox1" value="<%=(!mode.trim().equals("add"))?cdo.getColValue("fecha_sal"):cDateTime.substring(0,10)%>"/>
			                  </jsp:include>
							 </td>
							 <td>Año: &nbsp;<%=fb.textBox("anio",cdo.getColValue("ano"),false,false,true,7)%></td>
							 <td>No. Documento: &nbsp;&nbsp;<%=numDocSalida%></td>
						  </tr>

						  <tr class="<%=color%>">
						    <td>Tipo de Salida:</td>
								<td><%=fb.select(ConMgr.getConnection(),"select  tiposal.cod_salida, tiposal.descripcion||' - '||tiposal.cod_salida  descTipoSal from tbl_con_tipo_salida tiposal order by 2","tiposal",cdo.getColValue("tiposal"),"")%></td>
								<td align="right">Beneficiario:</td>
								<td>&nbsp;<%=fb.textBox("beneficiario",cdo.getColValue("beneficiario"),false,false,viewMode,60,50)%></td>
						  </tr>

						  <tr class="TextRow01">
                 <td>Valor de la Salida: </td>
                 <td colspan="3"><%=fb.decBox("valor_venta",cdo.getColValue("valor_venta"),false, false,viewMode,15,12.2,null,null,"","",false,"")%></td>
               </tr>

			 				<tr class="<%=color%>">
		        		<td>Explicación</td>
	            	<td colspan="3"><%=fb.textarea("explicacion",cdo.getColValue("explicacion"),true,false,viewMode,75,2,2000,null,"",null)%></td>
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

</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close

  secuencia = request.getParameter("secuencia");
  numDocSalida = request.getParameter("numDocSalida");

  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_salida_activos");
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("num_doc_sal",request.getParameter("numDocSalida"));
  cdo.addColValue("fecha_sal",request.getParameter("fecha_sal"));
  cdo.addColValue("ano",request.getParameter("anio"));
  cdo.addColValue("unid_sal",request.getParameter("ue_codigo"));
  cdo.addColValue("ubic_fis_sal",request.getParameter("nivel_codigo_ubic"));
  cdo.addColValue("cta1_espec",request.getParameter("cuentah_activo"));
  cdo.addColValue("cta2_sub",request.getParameter("cuentah_espec"));
  cdo.addColValue("cta3_detalle",request.getParameter("cuentah_detalle"));
  cdo.addColValue("tiposal",request.getParameter("tiposal"));
  cdo.addColValue("beneficiario",request.getParameter("beneficiario"));
  cdo.addColValue("valor_venta",request.getParameter("valor_venta"));
  cdo.addColValue("explicacion_salida",request.getParameter("explicacion"));
  cdo.addColValue("valor_ini",request.getParameter("valor_inicial"));
  cdo.addColValue("valor_actual",request.getParameter("valor_actual"));
  cdo.addColValue("dep_acum",request.getParameter("acum_deprec"));
  cdo.addColValue("valor_mejora",request.getParameter("valor__mejor_acum"));
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  
  if (mode.equalsIgnoreCase("add"))
  {
     cdo.addColValue("usu_crea", usuarioModificacion);
	 cdo.addColValue("fecha_crea",cDateTime);
     cdo.addColValue("usu_modif",usuarioModificacion);
     cdo.addColValue("fecha_modif", cDateTime);
	 cdo.addColValue("sec_activo", secuencia); 
	 cdo.setAutoIncCol("num_doc_sal");

     //CommonDataObject cdoPk = SQLMgr.getData("select nvl(max(to_number(SEC_ACTIVO)),0) + 1 as next_val from tbl_con_salida_activos where compania = "+((String) session.getAttribute("_companyId")));          
     
     SQLMgr.insert(cdo);
  }
  else
  {
     cdo.addColValue("usu_modif",usuarioModificacion);
     cdo.addColValue("fecha_modif", cDateTime);
     
     cdo.setWhereClause("sec_activo='"+secuencia+"' and compania="+(String) session.getAttribute("_companyId"));


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