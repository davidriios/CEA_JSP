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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String codigo = request.getParameter("codigo");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		codigo = "0";
	}
	else
	{
		if (codigo == null) throw new Exception("El Tipo factor de bundle no es válido. Por favor intente nuevamente!");

        sql = "select tm.codigo, tm.orden, tm.estado, tm.codigo_medida medida, tm.codigo_tubo tubo from tbl_sal_tubos_medidas tm where tm.codigo = "+codigo;
		cdo = SQLMgr.getData(sql);
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="NOSOCOMIAL BUNDLE - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="NOSOCOMIAL BUNDLE - Edición - "+document.title;
<%}%>

function preguntas(codigo, tubo, medida) {
  if (!codigo) alert('Por favor guarde antes de continuar!');
  else {
    var tuboDesc = $("#tubo").selText();
    var medidaDesc = $("#medida").selText();
    showPopWin('../expediente/exp_nosocomial_bundle_questions.jsp?codigo_bundle='+codigo+'&tubo='+tubo+'&medida='+medida+'&tubo_desc='+tuboDesc+'&medida_desc='+medidaDesc,winWidth*.95,winHeight*.85,null,null,'');
  }
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - NOSOCOMIAL BUNDLE"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",codigo)%>
			<tr>	
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="22%">&nbsp;<cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
				<td width="78">&nbsp;<%=codigo%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Orden:
                    <%=fb.intBox("orden",cdo.getColValue("orden"),false,false,false,5,2)%>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <a class="Link00Bold" href="javascript:preguntas('<%=cdo.getColValue("codigo"," ").trim()%>','<%=cdo.getColValue("tubo"," ").trim()%>','<%=cdo.getColValue("medida"," ").trim()%>')">Preguntas</a>
                </td>
            </tr>
            
            <tr class="TextRow01">
				<td>&nbsp;<cellbytelabel id="2">Tubo</cellbytelabel></td>
				<td>
                    <%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo as title from tbl_sal_tubos  order by codigo","tubo",cdo.getColValue("tubo"),false,false,0,"",null,"",null,"")%>
                </td>
			</tr>
            
            <tr class="TextRow01">
				<td>&nbsp;<cellbytelabel id="2">Medida</cellbytelabel></td>
				<td>
                    <%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo as title from tbl_sal_medidas  order by codigo","medida",cdo.getColValue("medida"),false,false,0,"",null,"",null,"")%>
                </td>
			</tr>
           
            <tr class="TextRow01"> 
                <td>&nbsp;<cellbytelabel id="3">Estado</cellbytelabel></td>
                <td>
                    <%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),"")%>
                </td>
            </tr>
            
			<tr class="TextRow02">
					<td align="right" colspan="2">
						<cellbytelabel id="4">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="5">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="6">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="7">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
							</tr>
				<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
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
else
 {
String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_sal_tubos_medidas");
  
  cdo.addColValue("orden",request.getParameter("orden"));
  cdo.addColValue("codigo_tubo",request.getParameter("tubo"));
  cdo.addColValue("codigo_medida",request.getParameter("medida"));
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("tipo",request.getParameter("medida").equals("1")?"I":"M");
   
  if (mode.equalsIgnoreCase("add")) {
     cdo.setAutoIncCol("codigo");
	 cdo.addPkColValue("codigo","");
     SQLMgr.insert(cdo);
	 codigo = SQLMgr.getPkColValue("codigo");
  }
  else {
   cdo.setWhereClause("codigo = "+request.getParameter("codigo"));
   SQLMgr.update(cdo);
  }
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_nosocomial_bundle_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_nosocomial_bundle_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/exp_nosocomial_bundle_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>