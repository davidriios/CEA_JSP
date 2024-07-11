<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
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

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String medico = request.getParameter("medico");

if (medico == null) medico = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
String cMedico = "";
String tipo = "";
String cTipo = "";
String orden = "";
boolean canAdd = false;

if (request.getMethod().equalsIgnoreCase("GET")) {

if (UserDet.getRefType().trim().equalsIgnoreCase("M")) cMedico = UserDet.getRefCode();
if (!medico.equals("")) cMedico = medico;

sql = "select d.id, d.usuario_creacion, d.usuario_modificacion, to_char(d.FECHA_CREACION, 'dd/mm/yyyy hh12:mi am') fc , to_char(d.FECHA_MODIFICACION, 'dd/mm/yyyy hh12:mi am') fm, d.medico, '['||d.medico||'] '||primer_nombre|| DECODE (segundo_nombre, NULL, '', ' ' || segundo_nombre)|| DECODE (primer_apellido, NULL, '', ' ' || primer_apellido)|| DECODE (segundo_apellido, NULL, '', ' ' || segundo_apellido)|| DECODE (sexo, 'F', DECODE (apellido_de_casada, NULL, '',' DE ' || apellido_de_casada)) AS nombre_medico from TBL_SAL_NOTAS_SOAP d, tbl_adm_medico m where d.pac_id = "+pacId+" and d.admision = "+noAdmision+" and d.medico = m.codigo order by d.id ";
al2 = SQLMgr.getDataList(sql);

sql = "select d.id, d.nota_s , d.nota_o, d.nota_a, d.nota_p ,primer_nombre|| DECODE (segundo_nombre, NULL, '', ' ' || segundo_nombre)|| DECODE (primer_apellido, NULL, '', ' ' || primer_apellido)|| DECODE (segundo_apellido, NULL, '', ' ' || segundo_apellido)|| DECODE (sexo, 'F', DECODE (apellido_de_casada, NULL, '',' DE ' || apellido_de_casada)) AS nombre_medico, d.medico from TBL_SAL_NOTAS_SOAP d, tbl_adm_medico m where d.pac_id = "+pacId+" and d.admision = "+noAdmision+" and d.medico = m.codigo ";

if (!id.equals("0")) sql += " and d.id = "+id;
else sql += " and d.medico = '"+cMedico+"'";

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

if (!cdo.getColValue("id"," ").trim().equals("")) {
  if (!viewMode) {
    mode = "edit";
    modeSec = "edit";
  }
} else {
  if (!viewMode) {
    mode = "add";
    modeSec = "add";
    canAdd = true;
  }
}

if (request.getParameter("viewing") != null ) {
  if (!cMedico.equals(cdo.getColValue("medico", " ").trim())) {
    
    if (!viewMode) {
      viewMode = true;
      canAdd = true;
    }
  } else {
    if (!viewMode) {
      mode = "edit";
      modeSec = "edit";
    }
  }
}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EVALUACION SOAP - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){setHeight();checkViewMode();}
function setHeight(){newHeight();}

function imprimir() {
  abrir_ventana("../expediente/print_notas_soap.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&seccion=<%=seccion%>&desc=<%=desc%>");
}

function ver(id) {
  window.location = "../expediente/notas_soap.jsp?pacId=<%=pacId%>&viewing=Y&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&id="+id;
}

function add() {
  window.location = "../expediente/notas_soap.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>";
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
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
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("desc",desc)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("orden",orden)%>
			<%=fb.hidden("cTipo", cdo.getColValue("tipo", cTipo))%>
			<tr>
					<td  colspan="6"  style="text-decoration:none;">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" class="child">
					 	<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextRow02">
			            <td colspan="6" align="right">&nbsp;</td>
		                </tr>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel>Listado de Evaluaciones</cellbytelabel></td>
							<td align="right" colspan="2">
                <%if(canAdd){%>
                &nbsp;<a href="javascript:add()" class="Link00">[ <cellbytelabel>Agregar</cellbytelabel> ]</a>
                <%}%>
                
                &nbsp;<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a>
              </td>
						</tr>
						<tr class="TextHeader" align="center">
								<td width="20%"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
								<td width="20%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
								<td width="20%"><cellbytelabel>Creado Por</cellbytelabel></td>
								<td width="20%"><cellbytelabel>Fecha Modificaci&oacute;n</cellbytelabel></td>
								<td width="20%"><cellbytelabel>Modificado Por</cellbytelabel></td>
							</tr>

<%
for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:ver('<%=cdo2.getColValue("id")%>')" align="center">
				<td><%=cdo2.getColValue("nombre_medico")%></td>
				<td><%=cdo2.getColValue("fc")%></td>
				<td><%=cdo2.getColValue("usuario_creacion")%></td>
				<td><%=cdo2.getColValue("fm")%></td>
				<td><%=cdo2.getColValue("usuario_modificacion")%></td>
		</tr>
<%
}
%>
						</table>
					</div>
					</div>
					</td>
				</tr>
				
			<tr class="TextRow02">
				<td colspan="3">
				<table border="0" cellpadding="0" cellspacing="0" class="TextRow02" width="100%">
					<tr class="TextRow01">
						<td colspan="4" align="right">&nbsp;</td>
					</tr>
					
					<tr class="TextRow02">
						<td colspan="4">
              M&eacute;dico:
              <%=fb.textBox("medico", cdo.getColValue("medico", cMedico),true,false,true,20,"Text10",null,null)%>
              <%=fb.textBox("nombre_medico", cdo.getColValue("nombre_medico", UserDet.getName()),false,false,true,160,"Text10",null,null)%>
						</td>
					</tr>
					
					<tr class="TextRow02">
						<td>&nbsp;<b>S (SECCIÓN SUBJETIVA): </b>&nbsp;<%=fb.textarea("nota_s",cdo.getColValue("nota_s"),true,false,viewMode,160,3,2000,"","","")%></td>
					</tr>
					
					<tr class="TextRow02">
						<td><b>&nbsp;O (OBSERVACIONES CLINICAS): </b>&nbsp;<%=fb.textarea("nota_o",cdo.getColValue("nota_o"),true,false,viewMode,160,3,2000,"","","")%></td>
					</tr>
					
					<tr class="TextRow02">
						<td><b>&nbsp;A (SECCIÓN DE ANALISIS): </b>&nbsp;<%=fb.textarea("nota_a",cdo.getColValue("nota_a"),true,false,viewMode,160,3,2000,"","","")%></td>
					</tr>
					
					<tr class="TextRow02">
						<td><b>&nbsp;P (PLAN): </b>&nbsp;<%=fb.textarea("nota_p",cdo.getColValue("nota_p"),true,false,viewMode,160,3,2000,"","","")%></td>
					</tr>
					
					
					
					

					
				</table>
				</td>
			</tr>
			

			<tr class="TextRow02" >
				<td colspan="3" align="right">
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
			</tr>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption")==null?"":request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	
	cdo = new CommonDataObject();
	cdo.setTableName("TBL_SAL_NOTAS_SOAP");
	cdo.addColValue("nota_s", request.getParameter("nota_s"));
	cdo.addColValue("nota_o", request.getParameter("nota_o"));
	cdo.addColValue("nota_a", request.getParameter("nota_a"));
	cdo.addColValue("nota_p", request.getParameter("nota_p"));

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());

        if(modeSec.trim().equals("add")){
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            cdo.addColValue("medico",  request.getParameter("medico"));
            cdo.addColValue("fecha_creacion", "sysdate");
            cdo.addColValue("fecha_modificacion", "sysdate");
            cdo.addColValue("usuario_creacion", (String)session.getAttribute("_userName"));
            cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
            
            cdo.setAutoIncWhereClause(" pac_id = "+pacId+" and admision = "+noAdmision);
            cdo.setAutoIncCol("id");
            cdo.addPkColValue("id","");
            SQLMgr.insert(cdo);
            id = SQLMgr.getPkColValue("id");
        }
        else {
            id = request.getParameter("id");
            cdo.addColValue("fecha_modificacion", "sysdate");
            cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
            cdo.setWhereClause(" pac_id = "+pacId+" and admision = "+noAdmision+" and medico = '"+ request.getParameter("medico")+"'");
            SQLMgr.update(cdo);
        }
    ConMgr.clearAppCtx(null);


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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&seccion=<%=seccion%>&desc=<%=desc%>';
<%
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>