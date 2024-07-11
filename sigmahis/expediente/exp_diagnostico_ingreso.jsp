<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />
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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cod_Historia ="0";
String key = "";
if (tab == null) tab = "0";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	

sql="select contacto ,parentezco_contacto ,telefono_contacto from tbl_adm_admision where pac_id = "+pacId+" and secuencia = "+noAdmision;
cdo1 = SQLMgr.getData(sql);
if(cdo1 == null){cdo1 =  new CommonDataObject();if (!viewMode) modeSec = "add";}
else if (!viewMode) modeSec = "edit";
if(change == null)
{
iDiag.clear();
vDiag.clear();

	// DIAGNOSTICOS DE INGRESO.

	sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc,a.icd10,b.icd_version as icdVersion from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'I' order by a.orden_diag";
  al = SQLMgr.getDataList(sql);
  for (int i=0; i<al.size(); i++)
  {
		cdo = (CommonDataObject) al.get(i);
    	cdo.setKey(i);
		cdo.setAction("U");
    try
    {
      iDiag.put(cdo.getKey(), cdo);
      vDiag.addElement(cdo.getColValue("diagnostico")+"-I");
    }
    catch(Exception e)
    {
      System.err.println(e.getMessage());
    }
  }
}//change
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE-DIAGNOSTICOS DE INGRESO '+document.title;
function doAction(){newHeight();<%if (request.getParameter("type") != null){%>showDiagnosticoList();<%}%>}
function showDiagnosticoList(){abrir_ventana1('../common/check_diagnostico.jsp?fp=pIngreso&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_89.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
		<td colspan="4" align="right"> <!-----> </td>
	</tr>
	<tr>
		<td>
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
				 <%=fb.hidden("diagSize",""+iDiag.size())%>
                  <%=fb.hidden("desc",desc)%>
<tr><td align="right" colspan="4"><a href="javascript:printExp();" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td></tr>
		  <tr class="TextHeader">
          	<td><cellbytelabel id="2">Diagn&oacute;sticos de Ingreso</cellbytelabel></td>
          </tr>
		  <tr>
          <td>
            <table width="100%" cellpadding="1" cellspacing="1">

			<tr class="TextHeader" align="center">
			  <td width="6%"><cellbytelabel id="3">Versi&oacute;n</cellbytelabel></td>
              <td width="12%"><cellbytelabel id="3">ICD</cellbytelabel></td>
			  <td width="12%"><cellbytelabel id="3">Equivalente ICD10</cellbytelabel></td>
              <td width="55%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
              <td width="10%"><cellbytelabel id="5">Prioridad</cellbytelabel></td>
              <td width="5%"><%=fb.submit("addDiagnostico","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnósticos")%></td>
            </tr>
			<%
			al.clear();
			al = CmnMgr.reverseRecords(iDiag);
			for (int i=0; i<iDiag.size(); i++)
			{
			 		key = al.get(i).toString();
					cdo = (CommonDataObject) iDiag.get(key);
			%>
            <%=fb.hidden("remove"+i,"")%>
            <%=fb.hidden("diagnostico"+i,cdo.getColValue("diagnostico"))%>
			<%=fb.hidden("icdVersion"+i,cdo.getColValue("icdVersion"))%>
			<%=fb.hidden("icd10"+i,cdo.getColValue("icd10"))%>
            <%=fb.hidden("diagnosticoDesc"+i,cdo.getColValue("diagnosticoDesc"))%>
            <%=fb.hidden("usuarioCreacion"+i,cdo.getColValue("usuario_creacion"))%>
            <%=fb.hidden("fechaCreacion"+i,cdo.getColValue("fecha_creacion"))%>
            <%=fb.hidden("usuarioModificacion"+i,cdo.getColValue("usuario_modificacion"))%>
            <%=fb.hidden("fechaModificacion"+i,cdo.getColValue("fecha_modificacion"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("ordenDiag"+i,cdo.getColValue("orden_diag"))%>
			<%}else{%>
            <tr class="TextRow01">
              <td><%=cdo.getColValue("icdVersion")%></td>
			  <td><%=cdo.getColValue("diagnostico")%></td>
			  <td><%=cdo.getColValue("icd10")%></td>
              <td><%=cdo.getColValue("diagnosticoDesc")%></td>
              <td align="center"><%=fb.intBox("ordenDiag"+i,cdo.getColValue("orden_diag"),false,false,viewMode,2)%></td>
              <td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diagnóstico")%></td>
            </tr>
			<%}%>
<%
}
%>
            </table>
          </td>
        </tr>
				<tr class="TextRow02">
					<td align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(error>0)newHeight();");%>
					<%=fb.formEnd(true)%>
				</table>

	</td>
</tr>
</table>

</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";

    //DIAGNOSTICOS
    int size = 0;
    if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
	iDiag.clear();
	vDiag.clear();
	al.clear();
    for (int i=0; i<size; i++)
    {
      CommonDataObject cdo2 = new CommonDataObject();
		  cdo2.setTableName("tbl_adm_diagnostico_x_admision");
		  cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='I' and diagnostico ='"+request.getParameter("diagnostico"+i)+"'" );
		  cdo2.addColValue("pac_id",request.getParameter("pacId"));
		  cdo2.addColValue("paciente",request.getParameter("codPac"));
		  cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
		  cdo2.addColValue("admision",request.getParameter("noAdmision"));
		  cdo2.addColValue("diagnostico",request.getParameter("diagnostico"+i));
		  cdo2.addColValue("diagnosticoDesc",request.getParameter("diagnosticoDesc"+i));
		  cdo2.addColValue("orden_diag",request.getParameter("ordenDiag"+i));
		  cdo2.addColValue("tipo","I");
		  cdo2.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"+i));
		  cdo2.addColValue("fecha_creacion",request.getParameter("fechaCreacion"+i));
		  cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		  cdo2.addColValue("fecha_modificacion",cDateTime);
		  cdo2.setKey(i);
  		  cdo2.setAction(request.getParameter("action"+i));
		  cdo2.addColValue("orden_diag",request.getParameter("ordenDiag"+i));
		  cdo2.addColValue("icdVersion",request.getParameter("icdVersion"+i));
		  cdo2.addColValue("icd10",request.getParameter("icd10"+i));
		  
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo2.getColValue("diagnostico")+"-I";
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}	
		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				al.add(cdo2);
				iDiag.put(cdo2.getKey(),cdo2);
				if(!cdo2.getAction().trim().equals("D"))vDiag.add(cdo2.getColValue("diagnostico")+"-I");
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
    }//End For

    if (!itemRemoved.equals(""))
    {
	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc);
      return;
    }
    if (baction != null && baction.equals("+"))
    {
      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc);
      return;
    }
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();
			cdo3.setTableName("tbl_adm_diagnostico_x_admision");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='I'");
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}


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

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
