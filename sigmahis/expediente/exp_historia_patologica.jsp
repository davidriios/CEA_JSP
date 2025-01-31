<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Interconsulta"%>
<%@ page import="issi.expediente.InterconsultaDiagnostico"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiagPre" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPre" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagPost" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPost" scope="session" class="java.util.Vector" />
<jsp:useBean id="iEspec" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String desc = request.getParameter("desc");

if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Secci�n no es v�lida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisi�n no es v�lida. Por favor intente nuevamente!");
if (tab == null) tab = "0";

int rowCount = 0;
String sql2 = "";

String change = request.getParameter("change");
String code = request.getParameter("code");
String filter ="", filter2 ="";
String key = "";
if(code == null)code = "0";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql=" select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha from tbl_sal_informe_patologico a where a.admision = "+noAdmision+" and a.pac_id = "+pacId+" order by to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc ";

al2 = SQLMgr.getDataList(sql);

if(!code.trim().equals("0"))
{
	sql = "select decode(a.patologo, null, a.nombre_patologo, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada))) as nombre_patologo,a.patologo,a.observacion, to_char(a.fecha,'dd/mm/yyyy') fecha,nvl(a.nombre_cirujano,'')nombre_cirujano from tbl_sal_informe_patologico a , tbl_adm_medico e where a.codigo="+code+" and a.patologo = e.codigo(+) ";
	cdo = SQLMgr.getData(sql);
	
if(change == null)
{

  	iDiagPre.clear();
	vDiagPre.clear();
	iDiagPost.clear();
	vDiagPost.clear();
	iEspec.clear();
	
 sql="select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPost,a.observacion from tbl_sal_diag_patologico  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_informe = "+code+"  order by a.codigo desc";
al = SQLMgr.getDataList(sql);
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);
        cdo1.setKey(i);
		cdo1.setAction("U");

        try
        {
          iDiagPost.put(cdo1.getKey(),cdo1);
          vDiagPost.addElement(cdo1.getColValue("diagnostico"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }

 sql="select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPre ,a.observacion from tbl_sal_diag_patologico  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_informe = "+code+"  order by a.codigo desc";
al = SQLMgr.getDataList(sql);
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);
        cdo1.setKey(i);
		cdo1.setAction("U");

        try
        {
          iDiagPre.put(cdo1.getKey(),cdo1);
          vDiagPre.addElement(cdo1.getColValue("diagnostico"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }

	sql="select  a.codigo code,a.codigo,nvl(a.especimen ,'') especimen from tbl_sal_especimen_patologico a where a.cod_informe = "+code+" order by a.codigo desc ";
al = SQLMgr.getDataList(sql);
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);

        cdo1.setKey(i);
		cdo1.setAction("U");

        try
        {
          iEspec.put(cdo1.getKey(),cdo1);
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }
}

if(!viewMode) modeSec = "edit";

}else if(code.trim().equals("0") || cdo == null)
{
		cdo = new CommonDataObject();
		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("hora",cDateTime.substring(11));

		if(!viewMode) modeSec = "add";
		if(change == null)
		{
		 iDiagPre.clear();
		 vDiagPre.clear();
		 iDiagPost.clear();
		 vDiagPost.clear();
		 iEspec.clear();
		}
}


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'INFORME HISTOPATOL�GICO - '+document.title;
function add(){window.location = '../expediente/exp_historia_patologica.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=0&desc=<%=desc%>';}
function showDiagPost(){abrir_ventana1('../common/check_diagnostico.jsp?fp=patologicoPost&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>');}
function showDiagPre(){abrir_ventana1('../common/check_diagnostico.jsp?fp=patologicoPre&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>');}
function setProtocolo(k){var code = eval('document.listado.codigo'+k).value;window.location = '../expediente/exp_historia_patologica.jsp?modeSec=view&seccion=<%=seccion%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code='+code;}
function doAction(){setHeight();<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1")){%>showDiagPre();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("2")){%>showDiagPost();<%}%>}
function imprimirEspecimen(){var fecha = eval('document.form0.fecha').value;abrir_ventana1('../expediente/print_informe_patologia.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&seccion=<%=seccion%>&fg=IP&desc=<%=desc%>&fechaProt='+fecha);}
function setHeight(){newHeight();}
function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=protocoloOp&fg='+fg);}
function clearMedico(){eval('document.form0.patologo').value="";}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="<%=desc%>"></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		    <table align="center" width="100%" cellpadding="5" cellspacing="0">


				<tr class="TextRow01">
					<td>
						<div id="proc" width="100%" class="exp h150">
						<div id="proced" width="98%" class="child">

							<table width="100%" cellpadding="1" cellspacing="0">

						 <%fb = new FormBean("listado","","");%>
						 <%=fb.formStart(true)%>
						 <%=fb.hidden("baction","")%>
						 <%=fb.hidden("mode",mode)%>
						 <%=fb.hidden("modeSec",modeSec)%>
						 <%=fb.hidden("seccion",seccion)%>
						 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
						 <%=fb.hidden("dob","")%>
						 <%=fb.hidden("codPac","")%>
						 <%=fb.hidden("pacId",pacId)%>
						 <%=fb.hidden("noAdmision",noAdmision)%>
						 <%=fb.hidden("code",code)%>
						 <%=fb.hidden("desc",desc)%> 
							<tr class="TextRow02">
								<td colspan="2">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
								<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar</cellbytelabel> ]</a><%}%> <a href="javascript:imprimirEspecimen()" class="Link00">[ <cellbytelabel id="3">Imprimir Informe</cellbytelabel> ]</a></td>
							</tr>

							<tr class="TextHeader">
								<td width="15%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
								<td width="15%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
								<td width="70%">&nbsp;</td>
							</tr>
	<%
	for (int i=1; i<=al2.size(); i++)
	{
		CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
	%>
			<%=fb.hidden("codigo"+i,cdo2.getColValue("codigo"))%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setProtocolo(<%=i%>)" style="text-decoration:none; cursor:pointer">

					<td><%=i%></td>
					<td><%=cdo2.getColValue("fecha")%></td>
					<td><%//=cdo2.getColValue("descProc")%></td>
			</tr>
	<%
	}%>

				<%=fb.formEnd(true)%>

				</table>
			</div>
			</div>
					</td>
				</tr>
	 </table>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("modeSec",modeSec)%>
					 <%=fb.hidden("seccion",seccion)%>
					 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
					 <%=fb.hidden("dob","")%>
					 <%=fb.hidden("codPac","")%>
					 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","0")%>
					 <%=fb.hidden("postSize",""+iDiagPost.size())%>
					 <%=fb.hidden("preSize",""+iDiagPre.size())%>
					 <%=fb.hidden("especSize",""+iEspec.size())%>
					 <%=fb.hidden("desc",desc)%>


									<tr class="TextRow01">
								<td colspan="4"><cellbytelabel id="5">Fecha</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include> </td>
						</tr>
								<tr class="TextRow01">
								<td width="25%"><cellbytelabel id="6">Historia Patol&oacute;gica Actual</cellbytelabel></td>
								<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),true,false,viewMode,60,3,4000,"","","")%></td>

						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="7">Cirujano</cellbytelabel></td>
						<td colspan="3">
								<%//=fb.hidden("patologo",""+cdo.getColValue("patologo"))%>
								<%=fb.textBox("nombre_cirujano",cdo.getColValue("nombre_cirujano"),false,false,false,45,150,"Text10","","")%>
								<%//=fb.button("btnLab","...",true,viewMode,null,null,"onClick=\"javascript:showMedicoList('PA')\"","")%></td>
						</tr>
						
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="8">Patologo</cellbytelabel></td>
						<td colspan="3">
								<%=fb.hidden("patologo",""+cdo.getColValue("patologo"))%>
								<%=fb.textBox("patologoNombre",cdo.getColValue("nombre_patologo"),false,false,viewMode,45,150,"Text10","","onChange=\"javascript:clearMedico()\"")%>
								<%=fb.button("btnLab","...",true,viewMode,null,null,"onClick=\"javascript:showMedicoList('PA')\"","")%></td>
						</tr>
 <%	fb.appendJsValidation("if(error>0)setHeight();");%>

						<tr class="TextRow02" align="right">
								<td colspan="4">
      	<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
								</td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
			<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("modeSec",modeSec)%>
					 <%=fb.hidden("seccion",seccion)%>
					 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
					 <%=fb.hidden("dob","")%>
					 <%=fb.hidden("codPac","")%>
					 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","1")%>
					 <%=fb.hidden("postSize",""+iDiagPost.size())%>
					 <%=fb.hidden("preSize",""+iDiagPre.size())%>
					 <%=fb.hidden("tipo","PR")%>
					 <%=fb.hidden("especSize",""+iEspec.size())%>
					 <%=fb.hidden("desc",desc)%>
						<tr class="TextHeader">
								<td width="10%"><cellbytelabel id="12">Diagn&oacute;stico</cellbytelabel></td>
								<td width="35%"><cellbytelabel id="13">Descripci&oacute;n</cellbytelabel></td>
								<td width="50%"><cellbytelabel id="14">Observaci&oacute;n</cellbytelabel></td>
								<td width="05%" align="center"><%=fb.submit("addDiag","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnostico Pre.")%></td>

					</tr>

<%
al = CmnMgr.reverseRecords(iDiagPre);
for (int i=0; i<iDiagPre.size(); i++)
{
  key = al.get(i).toString();
  cdo1 = (CommonDataObject) iDiagPre.get(key);

%>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("diagPre"+i,cdo1.getColValue("diagnostico"))%>
			 <%=fb.hidden("descDiagPre"+i,cdo1.getColValue("descDiagPre"))%>
			 <%=fb.hidden("observacion"+i,cdo1.getColValue("observacion"))%>
			<%}else{%>
			<tr class="TextRow01">
				<td><%=fb.textBox("diagPre"+i,cdo1.getColValue("diagnostico"),true,false,false,6,"Text10","","")%></td>
				<td><%=fb.textBox("descDiagPre"+i,cdo1.getColValue("descDiagPre"),false,false,true,40,"Text10","","")%></td>
				<td><%=fb.textarea("observacion"+i,cdo1.getColValue("observacion"),true,false,viewMode,40,3,2000,"","","")%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>
			</tr>

 <%	}}
		fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="4">
      	<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="10">Cerrar</cellbytelabel>
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
								</td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
			<!-- TAB1 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("modeSec",modeSec)%>
					 <%=fb.hidden("seccion",seccion)%>
					 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
					 <%=fb.hidden("dob","")%>
					 <%=fb.hidden("codPac","")%>
					 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","2")%>
					 <%=fb.hidden("postSize",""+iDiagPost.size())%>
					 <%=fb.hidden("preSize",""+iDiagPre.size())%>
					 <%=fb.hidden("tipo","PO")%>
					 <%=fb.hidden("especSize",""+iEspec.size())%>
					 <%=fb.hidden("desc",desc)%>
					<tr class="TextHeader">
								<td width="10%"><cellbytelabel id="12">Diagn&oacute;stico</cellbytelabel></td>
								<td width="35%"><cellbytelabel id="13">Descripci&oacute;n</cellbytelabel></td>
								<td width="50%"><cellbytelabel id="14">Observaci&oacute;n</cellbytelabel></td>
								<td width="05%" align="center"><%=fb.submit("addDiag","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnostico Post")%></td>

					</tr>

<%
al = CmnMgr.reverseRecords(iDiagPost);
for (int i=0; i<iDiagPost.size(); i++)
{
  key = al.get(i).toString();
  cdo1 = (CommonDataObject) iDiagPost.get(key);

%>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("diagPost"+i,cdo1.getColValue("diagnostico"))%>
			 <%=fb.hidden("descDiagPost"+i,cdo1.getColValue("descDiagPost"))%>
			 <%=fb.hidden("observacion"+i,cdo1.getColValue("observacion"))%>
			<%}else{%>
						<tr class="TextRow01">
						<td><%=fb.textBox("diagPost"+i,cdo1.getColValue("diagnostico"),true,false,true,6,"Text10","","")%></td>
						<td><%=fb.textBox("descDiagPost"+i,cdo1.getColValue("descDiagPost"),false,false,true,40,"Text10","","")%></td>
						<td><%=fb.textarea("observacion"+i,cdo1.getColValue("observacion"),true,false,viewMode,40,3,2000,"","","")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>
						</tr>


 <%	}}
	fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="4">
      	<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
								</td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
			<!-- TAB2 DIV END HERE-->
</div>

<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("modeSec",modeSec)%>
					 <%=fb.hidden("seccion",seccion)%>
					 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
					 <%=fb.hidden("dob","")%>
					 <%=fb.hidden("codPac","")%>
					 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","3")%>
					 <%=fb.hidden("postSize",""+iDiagPost.size())%>
					 <%=fb.hidden("preSize",""+iDiagPre.size())%>
					 <%=fb.hidden("especSize",""+iEspec.size())%>
					 <%=fb.hidden("desc",desc)%>
					<tr class="TextHeader">
								<td width="05%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
								<td width="90%"><cellbytelabel id="15">Esp&eacute;cimen</cellbytelabel></td>
								<td width="05%" align="center"><%=fb.submit("addEspec","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Esp�cimen")%></td>

					</tr>

					<%
al = CmnMgr.reverseRecords(iEspec);
for (int i=0; i<iEspec.size(); i++)
{
  key = al.get(i).toString();
  cdo1 = (CommonDataObject) iEspec.get(key);

				%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%=fb.hidden("code"+i,""+cdo1.getColValue("code"))%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("especimen"+i,cdo1.getColValue("especimen"))%>
			<%}else{%>
						<tr class="TextRow01">
						<td><%=cdo1.getColValue("code")%></td>
						<td><%=fb.textarea("especimen"+i,cdo1.getColValue("especimen"),true,false,viewMode,70,2,2000,"","","")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar.")%></td>
						</tr>


 <%	}}
	fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
								</td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
			<!-- TAB3 DIV END HERE-->
</div>

			</div>

<script type="text/javascript">
<%
String tabLabel = "'Datos Generales'";
if (!modeSec.equalsIgnoreCase("add")){
   tabLabel += ",'Diag. Pre-Operatorio.','Diag. Post-Operatorio','Esp�cimen'";
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");


	if (tab.equals("0")) //Protocolo
  {
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_informe_patologico");
	//cdo.setWhereClause("codigo="+request.getParameter("code"));
	cdo.addColValue("fecha",request.getParameter("fecha"));
	//cdo.addColValue("hora",request.getParameter("hora"));
	
	//cdo.addColValue("diag_pre_operatorio",request.getParameter("codDiagPre"));
	//cdo.addColValue("diag_post_operatorio",request.getParameter("diagPost"));
	//cdo.addColValue("procedimiento",request.getParameter("codProc"));
	cdo.addColValue("patologo",request.getParameter("patologo"));
	cdo.addColValue("nombre_patologo",request.getParameter("patologoNombre"));
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("nombre_cirujano",request.getParameter("nombre_cirujano"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));

		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");

		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo="+request.getParameter("code"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);

	}
	else if (tab.equals("1")) //diagnosticos pre operatorio.
	{
		int size = 0;
		if (request.getParameter("preSize") != null) size = Integer.parseInt(request.getParameter("preSize"));
		String itemRemoved = "",removedItem ="";
		iDiagPre.clear();
		vDiagPre.clear();
		al.clear();		
		for (int i=0; i< size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_diag_patologico ");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i));
				System.out.println(" CODIGO = ====== "+request.getParameter("codigo"+i));
				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i)); 
				cdo.addColValue("cod_informe",""+code);
				cdo.addColValue("diagnostico",request.getParameter("diagPre"+i));
				cdo.addColValue("descDiagPre",request.getParameter("descDiagPre"+i));
				cdo.addColValue("tipo",request.getParameter("tipo"));
				cdo.addColValue("observacion",request.getParameter("observacion"+i));
				
				cdo.setAction(request.getParameter("action"+i));
			    cdo.setKey(i);
			    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					itemRemoved = cdo.getKey();
					if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
					else cdo.setAction("D");
				}
				
				if (!cdo.getAction().equalsIgnoreCase("X"))
				{
					try
					{
						iDiagPre.put(cdo.getKey(),cdo);
						if(!cdo.getAction().trim().equals("D"))vDiagPre.add(cdo.getColValue("diagnostico"));
						al.add(cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
			return;
		}
		if(baction.equals("+"))//Agregar
		{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_diag_patologico");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB 1
	else if (tab.equals("2")) //diagnosticos post operatorio.
    {
		int size = 0;
		if (request.getParameter("postSize") != null) size = Integer.parseInt(request.getParameter("postSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		iDiagPost.clear();
		vDiagPost.clear();
		for (int i=0; i<size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_diag_patologico");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i));
System.out.println(" CODIGO = ====== "+request.getParameter("codigo"+i));
				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.addColValue("cod_informe",""+code);
				cdo.addColValue("diagnostico",request.getParameter("diagPost"+i));
				cdo.addColValue("descDiagPost",request.getParameter("descDiagPost"+i));
				cdo.addColValue("tipo",request.getParameter("tipo"));
				cdo.addColValue("observacion",request.getParameter("observacion"+i));
				cdo.setAction(request.getParameter("action"+i));
			    cdo.setKey(i);
			    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					itemRemoved = cdo.getKey();
					if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
					else cdo.setAction("D");
				}
				
				if (!cdo.getAction().equalsIgnoreCase("X"))
				{
					try
					{
						iDiagPost.put(cdo.getKey(),cdo);
						if(!cdo.getAction().trim().equals("D"))vDiagPost.add(cdo.getColValue("diagnostico"));
						al.add(cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
return;
		}
		if(baction.equals("+"))//Agregar
		{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=2&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_diag_patologico");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);

			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB 3
	else if (tab.equals("3")) //Esepcimen.
  {
    int size = 0;
    if (request.getParameter("especSize") != null) size = Integer.parseInt(request.getParameter("especSize"));
    String itemRemoved = "",removedItem ="";
		al.clear();
		iEspec.clear();
		for (int i=0; i<size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_especimen_patologico");
				cdo.setWhereClause("cod_informe="+code+" and codigo="+request.getParameter("codigo"+i));
				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_informe="+code+" ");
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				
				cdo.addColValue("cod_informe",""+code);
				cdo.addColValue("especimen",request.getParameter("especimen"+i));
				cdo.addColValue("code",request.getParameter("code"+i));

				cdo.setAction(request.getParameter("action"+i));
			    cdo.setKey(i);
			    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					itemRemoved = cdo.getKey();
					if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
					else cdo.setAction("D");
				}
				
				if (!cdo.getAction().equalsIgnoreCase("X"))
				{
					try
					{
						iEspec.put(cdo.getKey(),cdo);
						al.add(cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
return;
		}

		if(baction.equals("+"))//Agregar
		{
		cdo = new CommonDataObject();

		cdo.addColValue("codigo","0");
		cdo.addColValue("code","0");
		cdo.addColValue("especimen","");
		cdo.setAction("I");
		cdo.setKey(iEspec.size()+1);
		
		try
		{
			iEspec.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_especimen_patologico");
				cdo.setWhereClause("cod_informe="+code+" ");
				cdo.setAction("I");
				al.add(cdo);

			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

