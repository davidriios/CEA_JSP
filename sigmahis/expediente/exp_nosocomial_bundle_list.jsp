<%// @ page errorPage="../error.jsp"%>
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
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String company = (String)session.getAttribute("_companyId");
String tubo = request.getParameter("tubo")==null?"":request.getParameter("tubo");
String medida = request.getParameter("medida")==null?"":request.getParameter("medida");
String descripcion = request.getParameter("descripcion")==null?"":request.getParameter("descripcion");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String appendFilter = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (!tubo.trim().equals("") && !tubo.trim().equals("T")) appendFilter += " and tm.codigo_tubo = "+tubo;
if (!medida.trim().equals("") && !medida.trim().equals("T")) appendFilter += " and tm.codigo_medida = "+medida;
if (!status.trim().equals("") && !status.trim().equals("T")) appendFilter += " and tm.estado = '"+status+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql="select tm.codigo, tm.orden, t.nombre tubo_desc, m.nombre medida_desc, tm.estado, decode(tm.estado,'I','INACTIVO', 'A', 'ACTIVO') estado_desc , tm.codigo_medida, tm.codigo_tubo, (select count(*) from tbl_sal_tubo_medida_preguntas where codigo_tub_med = tm.codigo) tot_preguntas from tbl_sal_tubos_medidas tm, tbl_sal_tubos t, tbl_sal_medidas m where tm.codigo_tubo = t.codigo and tm.codigo_medida = m.codigo "+appendFilter+" order by tm.orden"; 

al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'EXPEDIENTE - PARAMETROS TRANSFERENCIA '+document.title;
function doAction(){}
function edit(codigo) {
    abrir_ventana('../expediente/exp_nosocomial_bundle_connfig.jsp?codigo='+codigo+'&mode=edit');
}
function add() {
    abrir_ventana('../expediente/exp_nosocomial_bundle_connfig.jsp');
}

function doFilter(obj){
  document.getElementById("search01").submit();
}

function preguntas(codigo, tubo, medida, tuboDesc, medidaDesc) {
  if (!codigo) alert('Por favor guarde antes de continuar!');
  else {
    showPopWin('../expediente/exp_nosocomial_bundle_questions.jsp?codigo_bundle='+codigo+'&tubo='+tubo+'&medida='+medida+'&tubo_desc='+tuboDesc+'&medida_desc='+medidaDesc,winWidth*.95,winHeight*.75,null,null,'');
  }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">

    <tr class="TextRow02">	
		<td colspan="4" align="right"> 
            <a class="Link00" href="javascript:add()">Agregar</a>
		</td>
	</tr>

	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="4">
			    Tubo&nbsp;
                <%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo as title from tbl_sal_tubos  order by codigo","tubo",tubo,false,false,0,"",null,"",null,"T")%>
                &nbsp;&nbsp;&nbsp;
			    Medidas&nbsp;
                <%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo as title from tbl_sal_medidas  order by codigo","medida",medida,false,false,0,"",null,"",null,"T")%>
			    &nbsp;&nbsp;&nbsp;
			    Estado&nbsp;<%=fb.select("status","T=-TODOS-,A=ACTIVO,I=INACTIVO",status,false,false,0,"","","onchange=doFilter(this)")%>
				<%=fb.submit("go","Ir",false,false,"",null,null)%>
			</td>
		<%=fb.formEnd()%>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				
				 <tr class="TextHeader">
				 	<td width="37%">Tubo</td>
				 	<td width="40%">Medida</td>
				 	<td align="center" width="5%">Estado</td>
				 	<td align="center" width="5%">Orden</td>
				 	<td width="13%">&nbsp;</td>
				 </tr>
				
				<% 
				 String grpTipo = "";
				 for (int i = 0; i<al.size(); i++){
					cdo = (CommonDataObject)al.get(i);
					String color = i%2==0?"TextRow02":"TextRow01";
				%>   
				   <%=fb.hidden("tubo"+i,cdo.getColValue("tubo"))%>
				   <%=fb.hidden("tipoDesc"+i,cdo.getColValue("tipo_desc"))%>
				   <%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				  
				  <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				 	<td><%=cdo.getColValue("tubo_desc")%> </td>
				 	<td><%=cdo.getColValue("medida_desc")%> </td>
				 	<td align="center"><%=cdo.getColValue("estado_desc")%> </td>
				 	<td align="center"><%=cdo.getColValue("orden")%> </td>
				 	<td align="center"> 
					<a class="Link00Bold" href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("codigo_tubo")%>','<%=cdo.getColValue("codigo_medida")%>')">Editar</a> / <a class="Link00Bold" href="javascript:preguntas('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("codigo_tubo")%>','<%=cdo.getColValue("codigo_medida")%>','<%=cdo.getColValue("tubo_desc")%>','<%=cdo.getColValue("medida_desc")%>')">Preguntas&nbsp;(<%=cdo.getColValue("tot_preguntas")%>)</a>
					</td>
				 </tr>
				<%
				grpTipo = cdo.getColValue("tubo");
				}
				%>
				
				 <%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>			

</table>
</body>
</html>
<%}%>