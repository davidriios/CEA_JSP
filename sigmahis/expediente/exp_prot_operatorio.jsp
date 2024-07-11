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
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iProcOpe" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProc" scope="session" class="java.util.Vector" />
<jsp:useBean id="vProcOpe" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String estado = request.getParameter("estado");

if (estado == null) estado = "";
if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
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
sql=" select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi am') fecha_modificacion, usuario_creacion, usuario_modificacion from tbl_sal_protocolo_operatorio a where a.admision = "+noAdmision+" and a.pac_id = "+pacId+" order by a.codigo desc ";

al2 = SQLMgr.getDataList(sql);
if(!code.trim().equals("0"))
{
	sql =" select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_operatorio codDiagPre, a.diag_post_operatorio diagPost, a.procedimiento codProc, a.cirujano, a.asistente,  a.anestesia, a.anestesiologo, a.profilaxis_antibiotica profilaxis, a.tiempo_profilaxis tiempoProfilaxis, a.limpieza, a.incision, a.especimen_patologia especimen, a.patologo, a.hallazgos,   a.observacion, a.complicacion,a.transfusiones,a.medicamentos,b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as cirujanoName,   decode(a.asistente,null,a.asistente,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada))) as nombre_asistente, decode(a.anestesiologo,null,a.anestesiologo,d.primer_nombre||decode(d.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada))) as nombre_anestesiologo, decode(a.patologo, null, a.patologo, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada))) as nombre_patologo,i.descripcion descAnestesia,nvl(a.suturas,'') suturas,nvl(a.drenaje,'')drenaje, to_char(a.hora_inicio,'hh12:mi am')hora_inicio,to_char(a.hora_fin,'hh12:mi am')hora_fin,nvl(a.instrumentador,'')instrumentador,nvl(a.circulador,'')circulador,nvl(a.protocolo,'')protocolo from tbl_sal_protocolo_operatorio a,  tbl_adm_medico b,tbl_adm_medico c,tbl_adm_medico d, tbl_adm_medico e,tbl_sal_tipo_anestesia i where  a.cirujano = b.codigo and a.asistente = c.codigo(+) and a.anestesiologo = d.codigo(+) and a.patologo = e.codigo(+) and a.anestesia = i.codigo and a.codigo = "+code;
cdo = SQLMgr.getData(sql);

if(change == null)
{

  iDiagPre.clear();
	vDiagPre.clear();
	iDiagPost.clear();
	vDiagPost.clear();
	iProc.clear();
	vProc.clear();
    
    // hack
    iProcOpe.clear();
    vProcOpe.clear();
	
 sql="select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPost from tbl_sal_diag_protocolo a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_protocolo = "+code+"  order by a.codigo desc";
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

 sql="select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPre from tbl_sal_diag_protocolo a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_protocolo = "+code+"  order by a.codigo desc";
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



 sql="select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_proc_protocolo a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.cod_protocolo = "+code+" order by a.codigo desc ";
al = SQLMgr.getDataList(sql);
      for (int i=0; i<al.size(); i++)
      {
        cdo1 = (CommonDataObject) al.get(i);
        cdo1.setKey(i);
	    cdo1.setAction("U");

		try
		{
		  iProc.put(cdo1.getKey(),cdo1);
          vProc.addElement(cdo1.getColValue("procedimiento"));
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
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("descProc","");
		cdo.addColValue("anestesiologo","");
		cdo.addColValue("asistente","");
		cdo.addColValue("patologo","");
		cdo.addColValue("hora_fin","");
		cdo.addColValue("hora_inicio","");

		if(!viewMode) modeSec = "add";
		if(change == null)
		{
		 iDiagPre.clear();
		 vDiagPre.clear();
		 iDiagPost.clear();
		 vDiagPost.clear();
		 iProc.clear();
		 vProc.clear();
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
document.title = 'PROTOCOLO OPERATORIO - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add(){	window.location = '../expediente/exp_prot_operatorio.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}
function showAnesList(){abrir_ventana1('../common/search_medico.jsp?fp=protocolo');}
function showProcList(){abrir_ventana1('../common/check_procedimiento.jsp?fp=exp_prot_operatorio&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=code%>&tab=<%=tab%>&desc=<%=desc%>');}
function showDiagPost(){abrir_ventana1('../common/check_diagnostico.jsp?fp=protocoloPost&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>');}
function showDiagPre(){abrir_ventana1('../common/check_diagnostico.jsp?fp=protocoloPre&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>');}

function setProtocolo(k, codigo, usuarioCreacion){
    var code = eval('document.listado.codigo'+k).value;
    var codes = $(".header").map(function() {
        return parseInt($(this).val(), 10)
    }).get();
    var cUser = "<%=(String)session.getAttribute("_userName")%>";
    
    if (arrayMax(codes) == codigo && cUser == usuarioCreacion) window.location = '../expediente/exp_prot_operatorio.jsp?modeSec=<%=!estado.trim().equals("") && !estado.trim().equalsIgnoreCase("F")?"edit":"view"%>&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&estado=<%=estado%>&code='+code;
    else window.location = '../expediente/exp_prot_operatorio.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&estado=<%=estado%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code='+code;
}

function arrayMax(arr) {
  var len = arr.length, max = -Infinity;
  while (len--) {
    if (arr[len] > max) {
      max = arr[len];
    }
  }
  return max;
}

function doAction(){setHeight();<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1")){%>showDiagPre();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("3")){%>showDiagPost();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("2")){%>	showProcList();<%}%>checkViewMode();}
function imprimirProtocolo(){var fecha = eval('document.form0.fecha').value;abrir_ventana1('../expediente/print_protocolo_op.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>&seccion=<%=seccion%>&fechaProt='+fecha);}
function setHeight(){newHeight();}
function showAnestesiaList(){abrir_ventana1('../expediente/list_anestesia.jsp?id=2');}
function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=protocoloOp&fg='+fg);}
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
						 <%=fb.hidden("estado",estado)%>
							<tr class="TextRow02">
								<td colspan="4">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
								<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar</cellbytelabel> ]</a><%}%><a href="javascript:imprimirProtocolo()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a></td>
							</tr>

							<tr class="TextHeader">
								<td width="15%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
								<td width="15%"><cellbytelabel id="5">Fecha</cellbytelabel></td>
								<td width="23%">U.Creaci&oacute;n</td>
								<td width="24%">U.Modificaci&oacute;n</td>
								<td width="23%">F.Modificaci&oacute;n</td>
							</tr>
	<%
	for (int i=1; i<=al2.size(); i++)
	{
		CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
	%>
			<%=fb.hidden("codigo"+i,cdo2.getColValue("codigo"))%>
            <input type="hidden" class="header" value="<%=cdo2.getColValue("codigo")%>">
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setProtocolo(<%=i%>, <%=cdo2.getColValue("codigo")%>, '<%=cdo2.getColValue("usuario_creacion"," ").trim()%>')" style="text-decoration:none; cursor:pointer">

					<td><%=cdo2.getColValue("codigo")%></td>
					<td><%=cdo2.getColValue("fecha")%></td>
					<td><%=cdo2.getColValue("usuario_creacion")%></td>
					<td><%=cdo2.getColValue("usuario_modificacion")%></td>
					<td><%=cdo2.getColValue("fecha_creacion")%></td>
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
					 <%=fb.hidden("procSize",""+iProc.size())%>
 					 <%=fb.hidden("desc",desc)%>
 					 <%=fb.hidden("estado",estado)%>

									<tr class="TextRow01">
								<td colspan="4"><cellbytelabel id="15">Fecha</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include> </td>
						</tr>
								<tr class="TextRow01">
								<td width="25%"><cellbytelabel id="16">Cirujano</cellbytelabel></td>
								<td colspan="3"><%//=fb.textBox("cirujano",cdo.getColValue("cirujano"),true,false,true,2,"Text10","","")%>
								<%=fb.hidden("cirujano",""+cdo.getColValue("cirujano"))%>
								<%=fb.textBox("cirujanoName",cdo.getColValue("cirujanoName"),true,false,true,45,"Text10","","")%>
								<%=fb.button("btnCirujao","...",true,viewMode,null,null,"onClick=\"javascript:showMedicoList('CR')\"","Cirujano")%></td>

						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="17">Medico Asistente</cellbytelabel></td>
						<td colspan="3"><%//=fb.textBox("asistente",cdo.getColValue("asistente"),false,false,true,2,"Text10","","")%>
								<%=fb.hidden("asistente",""+cdo.getColValue("asistente"))%>
								<%=fb.textBox("asistenteName",cdo.getColValue("nombre_asistente"),true,false,true,45,150,"Text10","","")%>
								<%=fb.button("btnAsistente","...",true,viewMode,null,null,"onClick=\"javascript:showMedicoList('AS')\"","Asistente")%></td>
						</tr>

						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="18">Anestesia</cellbytelabel></td>
						<td colspan="3"><%//=fb.textBox("anestesia",cdo.getColValue("anestesia"),true,false,true,2,"Text10","","")%>
						    <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_sal_tipo_anestesia order by 2","anestesia",cdo.getColValue("anestesia"),false,(viewMode),0,"Text10",null,null,"","")%>
								<%//=fb.textBox("descAnestesia",cdo.getColValue("descAnestesia"),false,false,true,45,"Text10","","")%>
								<%//=fb.button("btnAnestesia","...",true,viewMode,null,null,"onClick=\"javascript:showAnestesiaList()\"","Anestesia")%></td>
						</tr>

						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="19">Anestesiologo</cellbytelabel></td>
						<td colspan="3"><%//=fb.textBox("anestesiologo",cdo.getColValue("anestesiologo"),true,false,true,2,"Text10","","")%>
								<%=fb.hidden("anestesiologo",cdo.getColValue("anestesiologo"))%>
								<%=fb.textBox("anestesiologoNombre",cdo.getColValue("nombre_anestesiologo"),true,false,true,45,150,"Text10","","")%>
								<%=fb.button("btnAnes","...",true,viewMode,null,null,"onClick=\"javascript:showAnesList()\"","Anestesiologo")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="20">Instrumentador (a)</cellbytelabel>:</td>
						<td colspan="3">
								<%//=fb.hidden("instrumentador",""+cdo.getColValue("instrumentador"))%>
								<%=fb.textBox("instrumentador",cdo.getColValue("instrumentador"),false,false,viewMode,45,150,"Text10","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="21">Circulador (a)</cellbytelabel>:</td>
						<td colspan="3">
								<%//=fb.hidden("circulador",""+cdo.getColValue("circulador"))%>
								<%=fb.textBox("circulador",cdo.getColValue("circulador"),false,false,viewMode,45,150,"Text10","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="22">Hora</cellbytelabel>:</td>
						<td colspan="3"><cellbytelabel id="23">Inicio</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_inicio" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_inicio")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include> <cellbytelabel id="24">Fin</cellbytelabel>:<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_fin" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_fin")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include></td>
						</tr>
						
						
						
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="25">Profilaxis antibiotica</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("profilaxis",cdo.getColValue("profilaxis"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>

						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="26">Tiempo de la profilaxis antes de la incision</cellbytelabel></td>
						<td colspan="3">
						<%if(viewMode){%><%=fb.hidden("tiempoProfilaxis",""+cdo.getColValue("tiempoProfilaxis"))%><%}//else{%>
						<%=fb.select("tiempoProfilaxis","-1=A. NO PROFILAXIS,15=B. 15 MINUTOS ANTES,30=C. 30 MINUTOS ANTES,60=D. 60 MINUTOS ANTES,0=E. INMEDIATAMENTE DESPUES DE LA INCISION",cdo.getColValue("tiempoProfilaxis"), false, viewMode, 0,"",null,"",null,"")%>
						<%//}%>
						</td>
						</tr>

						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="27">Limpieza del Area</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("limpieza",cdo.getColValue("limpieza"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>

						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="28">Incision</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("incision",cdo.getColValue("incision"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						
						<tr class="TextRow01">
							<td width="25%"><cellbytelabel id="29">Espec&iacute;men para Patologia</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("especimen",cdo.getColValue("especimen"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr><!---->
		
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="30">Patologo</cellbytelabel></td>
						<td colspan="3">
								<%=fb.hidden("patologo",""+cdo.getColValue("patologo"))%>
								<%=fb.textBox("patologoNombre",cdo.getColValue("nombre_patologo"),false,false,viewMode,45,150,"Text10","","")%>
								<%=fb.button("btnLab","...",true,viewMode,null,null,"onClick=\"javascript:showMedicoList('PA')\"","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="31">Hallazgos Transoperatorios</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("hallazgos",cdo.getColValue("hallazgos"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="32">Protocolo Operatorio</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("protocolo",cdo.getColValue("protocolo"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="33">Observaci&oacute;n</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),true,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="34">Drenajes</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("drenaje",cdo.getColValue("drenaje"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="35">Sangrado</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("sangrado",cdo.getColValue("sangrado"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						<tr class="TextRow01">
						<td width="25%"><cellbytelabel id="36">Suturas</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("suturas",cdo.getColValue("suturas"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						

	<tr class="TextRow01">
	<td width="25%"><cellbytelabel id="37">Complicaciones</cellbytelabel></td>
	<td colspan="3"><%=fb.textarea("complicacion",cdo.getColValue("complicacion"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						
							<tr class="TextRow01">
	<td width="25%"><cellbytelabel id="38">Transfusiones o Infusiones</cellbytelabel></td>
	<td colspan="3"><%=fb.textarea("transfusiones",cdo.getColValue("transfusiones"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>
						
							<tr class="TextRow01">
	<td width="25%"><cellbytelabel id="39">Medicamentos</cellbytelabel></td>
	<td colspan="3"><%=fb.textarea("medicamentos",cdo.getColValue("medicamentos"),false,false,viewMode,60,3,2000,"","","")%></td>
						</tr>


 <%
 	fb.appendJsValidation("if(error>0)setHeight();");

	//fb.appendJsValidation("if(error>0)doAction();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="4">
      	<cellbytelabel id="40">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="41">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="42">Cerrar</cellbytelabel>
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
					 <%=fb.hidden("modeSec",modeSec)%><%=fb.hidden("seccion",seccion)%>
					 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
					 <%=fb.hidden("dob","")%>
					 <%=fb.hidden("codPac","")%>
					 <%=fb.hidden("pacId",pacId)%>
					 <%=fb.hidden("noAdmision",noAdmision)%>
					 <%=fb.hidden("code",code)%>
					 <%=fb.hidden("tab","1")%>
					 <%=fb.hidden("postSize",""+iDiagPost.size())%>
					 <%=fb.hidden("preSize",""+iDiagPre.size())%>
					 <%=fb.hidden("procSize",""+iProc.size())%>
					 <%=fb.hidden("tipo","PR")%>
                      <%=fb.hidden("desc",desc)%>
                      <%=fb.hidden("estado",estado)%>
						<tr class="TextHeader">
								<td width="15%"><cellbytelabel id="43">Diagnostico</cellbytelabel></td>
								<td width="80%"><cellbytelabel id="44">Descripci&oacute;n</cellbytelabel></td>
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
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("diagPre"+i,cdo1.getColValue("diagnostico"))%>
			 <%=fb.hidden("descDiagPre"+i,cdo1.getColValue("descDiagPre"))%>
			<%}else{%>
						<tr class="TextRow01">
						<td><%=fb.textBox("diagPre"+i,cdo1.getColValue("diagnostico"),true,false,false,10,"Text10","","")%></td>
						<td><%=fb.textBox("descDiagPre"+i,cdo1.getColValue("descDiagPre"),false,false,true,70,"Text10","","")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>
						</tr>

 <%	}}
		fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="40">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="41">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="42">Cerrar</cellbytelabel>
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
					 <%=fb.hidden("procSize",""+iProc.size())%>
 					 <%=fb.hidden("desc",desc)%>
                     <%=fb.hidden("estado",estado)%>
						<tr class="TextHeader">
								<td width="15%"><cellbytelabel id="45">Procedimiento</cellbytelabel></td>
								<td width="80%"><cellbytelabel id="44">Descripci&oacute;n</cellbytelabel></td>
								<td width="05%" align="center"><%=fb.submit("addDiag","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Procedimiento")%></td>

					</tr>

					<%
						al = CmnMgr.reverseRecords(iProc);
for (int i=0; i<iProc.size(); i++)
{
  key = al.get(i).toString();
  cdo1 = (CommonDataObject) iProc.get(key);

				%>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("procedimiento"+i,cdo1.getColValue("procedimiento"))%>
			 <%=fb.hidden("descProc"+i,cdo1.getColValue("descProc"))%>
			<%}else{%>
						<tr class="TextRow01">
						<td><%=fb.textBox("procedimiento"+i,cdo1.getColValue("procedimiento"),true,false,true,10,"Text10","","")%></td>
						<td><%=fb.textBox("descProc"+i,cdo1.getColValue("descProc"),false,false,true,70,"Text10","","")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Proc.")%></td>
						</tr>


 <%	}}
		fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="40">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="41">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="42">Cerrar</cellbytelabel>
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
					 <%=fb.hidden("procSize",""+iProc.size())%>
					 <%=fb.hidden("tipo","PO")%>
                     <%=fb.hidden("desc",desc)%>
                     <%=fb.hidden("estado",estado)%>
					<tr class="TextHeader">
								<td width="15%"><cellbytelabel id="43">Diagnostico</cellbytelabel></td>
								<td width="80%"><cellbytelabel id="44">Descripci&oacute;n</cellbytelabel></td>
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
			<%}else{%>
				<tr class="TextRow01">
					<td><%=fb.textBox("diagPost"+i,cdo1.getColValue("diagnostico"),true,false,true,10,"Text10","","")%></td>
					<td><%=fb.textBox("descDiagPost"+i,cdo1.getColValue("descDiagPost"),false,false,true,70,"Text10","","")%></td>
					<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>
				</tr>


 <%	}}
	fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="3">
      	<cellbytelabel id="40">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="41">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="42">Cerrar</cellbytelabel>
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
   tabLabel += ",'Diag. Pre-Operatorio.','Procedimientos','Diag. Post-Operatorio'";
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
	cdo.setTableName("tbl_sal_protocolo_operatorio");
	//cdo.setWhereClause("codigo="+request.getParameter("code"));
	cdo.addColValue("fecha",request.getParameter("fecha"));
	//cdo.addColValue("diag_pre_operatorio",request.getParameter("codDiagPre"));
	//cdo.addColValue("diag_post_operatorio",request.getParameter("diagPost"));
	//cdo.addColValue("procedimiento",request.getParameter("codProc"));
	cdo.addColValue("cirujano",request.getParameter("cirujano"));
	cdo.addColValue("asistente",request.getParameter("asistente"));
	cdo.addColValue("anestesia",request.getParameter("anestesia"));
	cdo.addColValue("anestesiologo",request.getParameter("anestesiologo"));
	cdo.addColValue("nombre_anestesiologo",request.getParameter("anestesiologoNombre"));
	cdo.addColValue("nombre_asistente",request.getParameter("asistenteName"));
	cdo.addColValue("profilaxis_antibiotica",request.getParameter("profilaxis"));
	cdo.addColValue("tiempo_profilaxis",request.getParameter("tiempoProfilaxis"));
	cdo.addColValue("limpieza",request.getParameter("limpieza"));
	cdo.addColValue("incision",request.getParameter("incision"));
	cdo.addColValue("especimen_patologia",request.getParameter("especimen"));
	cdo.addColValue("patologo",request.getParameter("patologo"));
	cdo.addColValue("nombre_patologo",request.getParameter("patologoNombre"));
	cdo.addColValue("hallazgos",request.getParameter("hallazgos"));
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("complicacion",request.getParameter("complicacion"));
	
	cdo.addColValue("drenaje",request.getParameter("drenaje"));
	cdo.addColValue("suturas",request.getParameter("suturas"));
	cdo.addColValue("sangrado",request.getParameter("sangrado"));
	
	cdo.addColValue("hora_inicio",request.getParameter("hora_inicio"));
	cdo.addColValue("hora_fin",request.getParameter("hora_fin"));
	
	cdo.addColValue("protocolo",request.getParameter("protocolo"));
	cdo.addColValue("circulador",request.getParameter("circulador"));
	cdo.addColValue("instrumentador",request.getParameter("instrumentador"));
	
	cdo.addColValue("transfusiones",request.getParameter("transfusiones"));
	cdo.addColValue("medicamentos",request.getParameter("medicamentos"));
	
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		cdo.addColValue("fecha_creacion", cDateTime);
		cdo.addColValue("usuario_creacion", (String)session.getAttribute("_userName"));
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");

		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo="+request.getParameter("code"));
        cdo.addColValue("fecha_modificacion", cDateTime);
		cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);

	}
	else if (tab.equals("1")) //diagnosticos pre operatorio.
    {
      int size = 0;
      if (request.getParameter("preSize") != null) size = Integer.parseInt(request.getParameter("preSize"));
      String itemRemoved = "",removedItem ="";
		al.clear();
		iDiagPre.clear();
		vDiagPre.clear();
		for (int i=0; i< size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_diag_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i));

				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					
					
					//cdo.setAutoIncWhereClause("cod_protocolo="+code+" and tipo = '"+request.getParameter("tipo")+"'");
					cdo.setAutoIncWhereClause("cod_protocolo="+code+"");
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.addColValue("cod_protocolo",""+code);
				cdo.addColValue("diagnostico",request.getParameter("diagPre"+i));
				cdo.addColValue("descDiagPre",request.getParameter("descDiagPre"+i));
				cdo.addColValue("tipo",request.getParameter("tipo"));
				
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

				cdo.setTableName("tbl_sal_diag_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB 1
	else if (tab.equals("2")) //Procedimiento pre operatorio.
    {
		int size = 0;
		if (request.getParameter("procSize") != null) size = Integer.parseInt(request.getParameter("procSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		vProc.clear();
		iProc.clear();
		for (int i=0; i<size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_proc_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" and codigo="+request.getParameter("codigo"+i));

				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_protocolo="+code);
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.addColValue("cod_protocolo",""+code);
				cdo.addColValue("procedimiento",request.getParameter("procedimiento"+i));
				cdo.addColValue("descProc",request.getParameter("descProc"+i));

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
						iProc.put(cdo.getKey(),cdo);
						if(!cdo.getAction().trim().equals("D"))vProc.add(cdo.getColValue("procedimiento"));
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
				cdo.setTableName("tbl_sal_proc_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" ");
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}
	}//END TAB 2
	else if (tab.equals("3")) //diagnosticos post operatorio.
    {
      int size = 0;
      if (request.getParameter("postSize") != null) size = Integer.parseInt(request.getParameter("postSize"));
      String itemRemoved = "",removedItem ="";
		al.clear();
		vDiagPost.clear();
		iDiagPost.clear();
		for (int i=0; i<size; i++)
		{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_diag_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i));

				if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
				{
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_protocolo="+code+"");
				}
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.addColValue("cod_protocolo",""+code);
				cdo.addColValue("diagnostico",request.getParameter("diagPost"+i));
				cdo.addColValue("descDiagPost",request.getParameter("descDiagPost"+i));
				cdo.addColValue("tipo",request.getParameter("tipo"));
				
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
return;
		}
		if(baction.equals("+"))//Agregar
		{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=3&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
				return;
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_diag_protocolo");
				cdo.setWhereClause("cod_protocolo="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);

			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB 3

%>
<html>
<head>
<script>
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

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&estado=<%=estado%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

