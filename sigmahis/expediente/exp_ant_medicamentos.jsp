<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iAntMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
ArrayList alDosis = new ArrayList();
ArrayList alViaAd = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
 
if (request.getMethod().equalsIgnoreCase("GET"))
{
		alDosis = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_grupo_dosis order by descripcion",CommonDataObject.class);
		alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='I' order by descripcion",CommonDataObject.class);

	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	if (change == null)
	{	iAntMed.clear();
		sql = "select renglon, nvl(descripcion,' ') as descripcion, nvl(dosis,' ') as dosis, nvl(observacion,' ') as observacion, usuario_creac, to_char(fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, usuario_modif, to_char(fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fecha_modif, decode(via_admin,null,' ',''||via_admin) as via_admin, decode(cod_grupo_dosis,null,' ',''||cod_grupo_dosis) as cod_grupo_dosis, nvl(cod_frecuencia,' ') as cod_frecuencia, decode(cada,null,' ',''||cada) as cada, nvl(tiempo,' ') as tiempo, nvl(frecuencia,' ') as frecuencia, fn_sal_ant_history("+pacId+", "+noAdmision+", "+seccion+",'admision','descripcion',null,null) history from tbl_sal_antecedent_medicamento where pac_id="+pacId+" and nvl(admision,"+noAdmision+") = "+noAdmision;

		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");
			try
			{
				iAntMed.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();

			cdo.addColValue("renglon","0");
			cdo.setKey(iAntMed.size() + 1);
			cdo.setAction("I");
			try
			{
				iAntMed.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";
	}//change=null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Antecedente Medicamento - '+document.title;
function doAction(){newHeight();}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_27.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function alertVA(){var size = <%=iAntMed.size()%>;for(i=0;i<size;i++){if(eval('document.form0.action'+i).value!='D'){if(eval('document.form0.via'+i).value==''){alert("Recuerde seleccionar la vía de administracíon");break;}}}}

$(function(){
  $(".history").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#historyCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
  });
});
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
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("aMedSize",""+iAntMed.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>

		<tr class="TextRow02">
			<td colspan="5" align="right"><a href="javascript:imprimir()"  class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="2">Medicamento</cellbytelabel></td>
			<td width="11%"><cellbytelabel id="3">Concentraci&oacute;n</cellbytelabel></td>
			<td width="19%"><cellbytelabel id="4">Forma</cellbytelabel></td>
			<!--<td width="11%">Cada</td>
			<td width="15%">Tiempo</td>-->
			<td width="16%"><cellbytelabel id="5">Frecuencia</cellbytelabel></td>
          <td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); alertVA();\"","Agregar Medicamento")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iAntMed);
boolean flagModify=false;
for (int i=0; i<iAntMed.size(); i++)
{
	 key = al.get(i).toString();
	 cdo = (CommonDataObject) iAntMed.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	 String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
	 
	 String history = cdo.getColValue("history")==null?"":"Historial";
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("usuario_creac"+i,cdo.getColValue("USUARIO_CREAC"))%>
		<%=fb.hidden("fecha_creac"+i,cdo.getColValue("FECHA_CREAC"))%>
		<%=fb.hidden("renglon"+i,cdo.getColValue("RENGLON"))%>
		<%=fb.hidden("cod_frecuencia"+i,cdo.getColValue("COD_FRECUENCIA"))%>
		<%=fb.hidden("history"+i,cdo.getColValue("history"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		<%=fb.hidden("historyCont"+i,"<label class='historyCont' style='font-size:11px'>"+(cdo.getColValue("history")==null?"":cdo.getColValue("history"))+"</label>")%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("dosis"+i,cdo.getColValue("dosis"))%>
		<%=fb.hidden("forma"+i,cdo.getColValue("cod_grupo_dosis"))%>
		<%=fb.hidden("frecuencia"+i,cdo.getColValue("frecuencia"))%>
		<%=fb.hidden("via"+i,cdo.getColValue("via_admin"))%>
		<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		<%}else{%>
		<tr class="<%=color%>" align="center"  <%=style%>>
			<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,flagModify,viewMode,20,"Text10",null,null)%>
			<span class="history" title="" data-i="<%=i%>"><span class="Link00 pointer"><%=history%></span></span>
			</td>
			<td><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),false,false,viewMode,3,"Text10",null,null)%></td>
			<td><%=fb.select("forma"+i,alDosis,cdo.getColValue("cod_grupo_dosis"),false,viewMode,0,"Text10",null,null,"","S")%></td>
			<!--<td><%//=fb.decBox("cada"+i,cdo.getColValue("CADA"),false,false,viewMode,3,3.2,"Text10",null,null)%></td>
			<td><%//=fb.select("tiempo"+i,"SEG=SEGUNDOS, MIN=MINUTOS, HRS=HORAS, DIA=DIAS, SEM=SEMANAS, MES=MESES",cdo.getColValue("TIEMPO"),false,viewMode,0,"Text10",null,null,"","S")%></td>-->
			<td><%=fb.textBox("frecuencia"+i,cdo.getColValue("frecuencia"),false,false,viewMode,12,"Text10",null,null)%></td>
			<td ><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
		<tr class="<%=color%>" <%=style%>>
			<td colspan="2" valign="top">
				<cellbytelabel id="6">V&iacute;a de Administraci&oacute;n</cellbytelabel>
				<br>
				<%=fb.select("via"+i,alViaAd,cdo.getColValue("via_admin"),false,viewMode,0,"Text10",null,null,"","S")%>
			</td>
			<td colspan="4">
				<cellbytelabel id="7">Observaciones</cellbytelabel>
				<br>
				<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,2,2000,"","width:100%","")%>
			</td>
		</tr>
		<%}%>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="9">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="10">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); alertVA();\"")%>
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
	int size = Integer.parseInt(request.getParameter("aMedSize"));

	String itemRemoved = "";
	al.clear();
	iAntMed.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_SAL_ANTECEDENT_MEDICAMENTO");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and renglon ="+request.getParameter("renglon"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));

		if (request.getParameter("renglon"+i).equals("0")||request.getParameter("renglon"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("RENGLON");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));
			cdo.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
			cdo.addColValue("FECHA_CREAC","sysdate");
			cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
			cdo.addColValue("FECHA_MODIF","sysdate");
		}
		else
		{
			cdo.addColValue("RENGLON",request.getParameter("renglon"+i));
			cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"+i));
			cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"+i));
			cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
			cdo.addColValue("FECHA_MODIF","sysdate");
		}

		cdo.addColValue("COD_FRECUENCIA",request.getParameter("cod_frecuencia"+i));
		cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"+i));
		cdo.addColValue("DOSIS",request.getParameter("dosis"+i));
		cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
		cdo.addColValue("VIA_ADMIN",request.getParameter("via"+i));
		cdo.addColValue("COD_GRUPO_DOSIS",request.getParameter("forma"+i));
		cdo.addColValue("history",request.getParameter("history"+i));
		//cdo.addColValue("CADA",request.getParameter("cada"+i));
		//cdo.addColValue("TIEMPO",request.getParameter("tiempo"+i));
		cdo.addColValue("FRECUENCIA",request.getParameter("frecuencia"+i));
		cdo.setKey(i);
  		cdo.setAction(request.getParameter("action"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}	
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				al.add(cdo);
				iAntMed.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for

	if (!itemRemoved.equals(""))
	{
		//iAntMed.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));
		return;
	}
	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("renglon","0");
		cdo.setAction("I");
		cdo.setKey(iAntMed.size() + 1);
		try
		{
			iAntMed.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc"));
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_antecedent_medicamento");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
			cdo.setAction("I");
			al.add(cdo);
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
















