<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hashAten" scope="session" class="java.util.Hashtable" />
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
String compania = (String) session.getAttribute("_companyId");
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (mode == null || mode.equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";
String id = request.getParameter("id");
if ( id == null ) id = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	//sql = "select pac_id, to_char(fecha_ayuda,'dd/mm/yyyy') fechaAyuda,nvl(observ_ayuda,' ') observacion from tbl_adm_admision where pac_id = "+pacId+" and secuencia =  "+noAdmision;
	
	sql = "select a.id, a.DESCRIPCION, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') FECHA_CREACION, a.usuario_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') FECHA_MODIFICACION from tbl_sal_atencion_espiritual a where a.pac_id = "+pacId+" and admision = "+noAdmision+" and a.compania = "+compania+" order by a.FECHA_CREACION desc";
	
	al = SQLMgr.getDataList(sql);
	
	if(!id.trim().equals("0")){
		sql = "select a.id, a.DESCRIPCION observacion, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') FECHA_MODIFICACION, a.compania from   tbl_sal_atencion_espiritual a where a.pac_id = "+pacId+" and admision = "+noAdmision+" and a.compania = "+compania+" and a.id = "+id+" order by a.FECHA_CREACION desc";
		
		cdo1 = SQLMgr.getData(sql);
	}// id is not zero, update viewMode = true
	
	//if ( cdo1 == null ) cdo1 = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - ATENCION ESPIRITUAL - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_58.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&id=<%=id%>");}
function setAtencion(a){var id = eval('document.lista.id'+a).value;	window.location = '../expediente3.0/exp_atencion_espiritual.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&id='+id;}
function add(){window.location = '../expediente3.0/exp_atencion_espiritual.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&id=0';}
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

<tr class="TextRow01">
 <%fb = new FormBean("lista",request.getContextPath()+request.getServletPath());%>
 <%=fb.formStart(true)%>
 <%=fb.hidden("desc",desc)%>
   <td>
       <div id="atencion" width="100%" class="exp h100">
	   <div id="atencion" width="98%" class="child">
       
       <table width="100%" cellpadding="1" cellspacing="0">
       			<tr class="TextRow02">
								<td align="right" colspan="5">
                                  <% if ( !mode.equals("view") ) {%>
                                    <a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Agregar Atenci&oacute;n</cellbytelabel> ]</a>
                                  <%}%> 
                                  <% if ( !id.equals("0") ) {%>     
                                    <a href="javascript:printExp()" class="Link00">[ <cellbytelabel id="2">Imprimir</cellbytelabel> ]</a>
                                  <%}if(al.size()>0){%> 
                                    <a href="javascript:printExp()" class="Link00">[ <cellbytelabel id="3">Imprimir Todo</cellbytelabel> ]</a>
                                  <%}%> </td>
							</tr>
							<tr class="TextHeader">
                            	<td width="10%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
								<td width="20%"><cellbytelabel id="5">F. Creaci&oacute;n</cellbytelabel></td>
								<td width="20%"><cellbytelabel id="6">Creada Por</cellbytelabel></td>
                                <td width="30%"><cellbytelabel id="7">F. Modificaci&oacute;n</cellbytelabel></td>
                                <td width="20%"><cellbytelabel id="8">Modificada Por</cellbytelabel></td>
				           </tr>
                           <%
						   for (int a = 1; a<=al.size(); a++){
							    cdo = (CommonDataObject)al.get(a-1);
								String color = "TextRow02";
		                        if (a % 2 == 0) color = "TextRow01";
								%>
                           
                           <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setAtencion(<%=a%>)" style="text-decoration:none; cursor:pointer">
                           <td><%=cdo.getColValue("id")%></td>
                           <td><%=cdo.getColValue("FECHA_CREACion")%></td>
                           <td><%=cdo.getColValue("usuario_creacion")%></td>
                           <td><%=cdo.getColValue("FECHA_modificacion")%></td>
                           <td><%=cdo.getColValue("usuario_modificacion")%></td>
                           </tr>
                           <%=fb.hidden("id"+a,cdo.getColValue("id"))%>
							<% 
						      }
						   %>
       </table>
       </div>
       </div>
   </td>
    <%=fb.formEnd(true)%>
</tr>




<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td>
				<cellbytelabel id="9">Fecha</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="fechaCreacion" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo1.getColValue("fecha_creacion")==null?cDateTime:cdo1.getColValue("fecha_creacion"))%>" />
                <jsp:param name="readonly" value="<%=(viewMode||(!modeSec.equals("add")))?"y":"n"%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>
				<cellbytelabel id="10">Observaci&oacute;n</cellbytelabel>
				<%=fb.textarea("observacion",cdo1.getColValue("observacion"),true,false,false,60,6,2000,"","width:100%","")%>
                <%=fb.hidden("usuarioCreacion",cdo1.getColValue("usuario_creacion"))%>
                <%=fb.hidden("fechaCreacion",cdo1.getColValue("fecha_creacion"))%>
                <%=fb.hidden("id",cdo1.getColValue("id"))%>
                <%=fb.hidden("compania",cdo1.getColValue("compania"))%>
			</td>
		</tr>
		<tr class="TextRow02" align="right">
			<td>
				<cellbytelabel id="11">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="12">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="13">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%fb.appendJsValidation("if(error>0)doAction();");%>
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

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_atencion_espiritual");
	
	cdo.addColValue("descripcion",request.getParameter("observacion"));
	
	if ( modeSec.equals("add") ){
		 cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	     cdo.addColValue("fecha_creacion",cDateTime);
		 cdo.addColValue("compania",compania);
		
		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");
		 
	}else{
		cdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
		cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));
		cdo.addColValue("compania",request.getParameter("compania"));
	}
	
	cdo.addColValue("USUARIO_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("FECHA_modificacion",cDateTime);
	
	cdo.addColValue("pac_id",request.getParameter("pacId"));
	cdo.addColValue("admision",request.getParameter("noAdmision"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	
	if ( modeSec.equals("add") ){
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("id");
	}
	else{
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision")+" and compania = "+request.getParameter("compania")+" and id = "+id);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

