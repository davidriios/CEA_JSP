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

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	sql = "select a.codigo,a.edad, a.descripcion, b.crecimiento,decode(b.crecimiento,null,'N','S') valor,decode(a.edad,1,'2 MESES',2,'4 MESES',3,'6 MESES',4,'9 MESES',5,'12 MESES',6,'18 MESES',7,'2 AÑOS',8,'3 AÑOS',9,'5 AÑOS',10,'OTRAS') descEdad, b.meses, b.pac_id,decode(b.crecimiento,null,'I','U') action,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.usuario_creacion from  tbl_sal_crecimiento_desarrollo a, tbl_sal_crecimiento_paciente b where a.codigo=b.crecimiento(+) and b.pac_id(+)="+pacId+" and a.edad is not null order by a.edad,a.orden";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - Crecimiento y Desarrollo - '+document.title;
function doAction(){newHeight();}
function setCheck(k,edad,obj){
var valor = eval('document.form0.edadValor'+k).value;
var size  = '<%=al.size()%>';if(obj.checked){for (i=0; i<size; i++){if(eval('document.form0.edadValor'+i).value ==valor){eval('document.form0.valor'+i).disabled = false;}else  {eval('document.form0.valor'+i).checked=false;eval('document.form0.valor'+i).disabled = true;}}}else{for (l=0; l<size; l++){if(eval('document.form0.edadValor'+l).value != valor){eval('document.form0.valor'+l).checked = false;eval('document.form0.valor'+l).disabled = false;}}}}
function imprimirExp(){	abrir_ventana('../expediente/print_exp_seccion_13.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');}
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
		<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02" >
			<td colspan="5" align="right">&nbsp;<a href="javascript:imprimirExp()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextHeader" align="center" >
			<td width="15%"><cellbytelabel id="4">Edad</cellbytelabel></td>
			<td width="80%"><cellbytelabel id="5">Desarrollo Psicomotor</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>

		<tr class="TextRow01">
				<td colspan="3">
		<div id="listado2" width="100%" class="exp h350">
					<div id="detListado2" width="98%" class="child">
				<table width="100%" cellpadding="1" cellspacing="0">
		<!---<tr class="TextRow01" align="center">
			<td colspan="3">sssssssssssssssssssss
				<div id="proc" width="100%" style="overflow:scroll;position:relative;height:300">
					<div id="proced" width="98%" style="overflow;position:absolute">
						<table width="100%" cellpadding="1" cellspacing="0">--->

<%
String edad ="";
String color = "TextRow02";

for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);

	//if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,""+cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,""+cdo.getColValue("descripcion"))%>
		<%=fb.hidden("edad"+i,""+cdo.getColValue("edad"))%>
		<%=fb.hidden("meses"+i,""+cdo.getColValue("meses"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%
		if(!edad.trim().equals(cdo.getColValue("edad")))
		{


		 if (color.trim().equals("TextRow01")) color = "TextRow02";
		 else color = "TextRow01";

		if(i !=0)
		{

		%>

			  		</table>
				</td>
			<td align="left" width="5%">&nbsp;</td>
		</tr>


		<%
		}
		%>



		<tr class="<%=color%>">
			<td width="15%"><%=cdo.getColValue("descEdad")%></td>


				<td width="80%">
				<table width="100%" cellpadding="1" cellspacing="1">
			<%}//else{%>

					<tr class="<%=color%>">
						<td width="90%"><%=cdo.getColValue("descripcion")%></td>
						<td width="10%">
						<%=fb.hidden("edadValor"+i,""+cdo.getColValue("edad"))%>
						<%=fb.checkbox("valor"+i,"S",(cdo.getColValue("valor").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:setCheck("+i+","+cdo.getColValue("edad")+",this)\"")%>
						</td>
					</tr>
<%//}//end else
edad=cdo.getColValue("edad");

if(i==al.size()-1)
{%>
			  		</table>
				</td>
			<td align="left">&nbsp;</td>
		</tr>
<%
}

}

fb.appendJsValidation("if(error>0)doAction();");
%>
				<!---</table>
			</div>
		</div>
		</td>
		</tr>--->

				</table>
		</td>
</tr>
		<tr class="TextRow02" align="right">
			<td colspan="3">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
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
	int size= Integer.parseInt(request.getParameter("size"));

	al.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_crecimiento_paciente");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and crecimiento="+request.getParameter("codigo"+i));
			
		if (request.getParameter("valor"+i)!= null && request.getParameter("valor"+i).trim().equals("S"))
		{
			cdo.addColValue("fec_nacimiento",request.getParameter("dob"));
			cdo.addColValue("cod_paciente",request.getParameter("codPac"));
			cdo.addColValue("pac_id",request.getParameter("pacId"));
			cdo.addColValue("admision",request.getParameter("noAdmision"));//
			cdo.addColValue("meses",request.getParameter("edad"+i));
			cdo.addColValue("crecimiento",request.getParameter("codigo"+i));
			cdo.setAction(request.getParameter("action"+i));
			if(request.getParameter("usuario_creacion"+i) == null ||request.getParameter("usuario_creacion"+i).trim().equals(""))
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			else cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			if(request.getParameter("fecha_creacion"+i) == null ||request.getParameter("fecha_creacion"+i).trim().equals(""))
			cdo.addColValue("fecha_creacion",cDateTime);
			else cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			al.add(cdo);
		}//End if
		else if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U"))
		{
			cdo.setAction("D");
			al.add(cdo);
		}
		
	}//End For

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_crecimiento_paciente");
		cdo.setWhereClause("pac_id="+pacId+" and admision ="+request.getParameter("noAdmision"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
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
