<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (fg == null) fg = "";
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

	/*sbSql.append("select count(*) as nant from tbl_sal_antecedent_medicamento where pac_id = ")
		.append(request.getParameter("pacId"))
		.append(" and admision < ")
		.append(request.getParameter("noAdmision"));*/
	sbSql.append("select count(*) as nant from tbl_sal_antecedent_medicamento z where exists ( select null from ( ")
			.append("select pac_id, admision, count(*) as nrecs, row_number() over (order by admision desc) as rn from tbl_sal_antecedent_medicamento where pac_id = ")
			.append(request.getParameter("pacId"))
			.append(" and admision < ")
			.append(request.getParameter("noAdmision"))
			.append(" group by pac_id, admision having count(*) > 0")
		.append(" ) where rn = 1 and pac_id = z.pac_id and admision = z.admision")
		//control para no permitir recuperar los items ya recuperados
		.append(" and not exists ( select null from tbl_sal_antecedent_medicamento where pac_id = ")
			.append(request.getParameter("pacId"))
			.append(" and admision = ")
			.append(request.getParameter("noAdmision"))
			.append(" and recovered_rn = z.renglon )")
		.append(" )");
	cdo = SQLMgr.getData(sbSql.toString());
	boolean hasAnt = !cdo.getColValue("nant").equals("0");

	if (change == null) {
		iAntMed.clear();
		sbSql = new StringBuffer();
		sbSql.append("select renglon, nvl(descripcion,' ') as descripcion, nvl(dosis,' ') as dosis, nvl(observacion,' ') as observacion, usuario_creac, to_char(fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, usuario_modif, to_char(fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fecha_modif, decode(via_admin,null,' ',''||via_admin) as via_admin, decode(cod_grupo_dosis,null,' ',''||cod_grupo_dosis) as cod_grupo_dosis, nvl(cod_frecuencia,' ') as cod_frecuencia, decode(cada,null,' ',''||cada) as cada, nvl(tiempo,' ') as tiempo, nvl(frecuencia,' ') as frecuencia, user_ref_code, admision, decode(recovered_adm,null,' ',''||recovered_adm) as recovered_adm, decode(recovered_rn,null,' ',''||recovered_rn) as recovered_rn from tbl_sal_antecedent_medicamento where pac_id = ")
			.append(pacId)
			.append(" and nvl(admision,")
			.append(noAdmision);
		if (fg.trim().equals("history")) sbSql.append(") < ");
		else sbSql.append(") = ");
		sbSql.append(noAdmision)
			.append(" order by admision ");
		al = SQLMgr.getDataList(sbSql.toString());
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
	 <!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<meta charset="utf-8">
		<title>Expediente Cellbyte</title>

		<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
document.title = 'Antecedente Medicamento - '+document.title;
var noNewHeight = true;
function doAction(){
<%if (fg.trim().equalsIgnoreCase("history")){%>$("#loadingmsg").remove();<%}%>
}
function doPrint(){abrir_ventana('../expediente3.0/print_exp_seccion_27.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function alertVA(){var size = <%=iAntMed.size()%>;for(i=0;i<size;i++){if(eval('document.form0.action'+i).value!='D'){if(eval('document.form0.via'+i).value==''){alert("Recuerde seleccionar la vía de administracíon");break;}}}}


function printConciliacion() {
	var q = "?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>";
	abrir_ventana("../expediente3.0/exp_print_conciliacion.jsp"+q);
}

function showHistory() {
var url = encodeURI("<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=view&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=history");
parent.loadModal(url, {title: 'Historial de Medicamentos'});
}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

		<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<!--INICIO de una fila de elementos-->
		<div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
<%=fb.hidden("fg",fg)%>

				<%if(fg.trim().equals("")){%>
				<div class="headerform">
		<!--tabla de boton imprimir-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
		<td>
				<%if (!noAdmision.trim().equals("1")){%>
						<%=(seccion.equals("27"))?fb.submit("recuperar","RECUPERAR",true,!hasAnt||viewMode,"btn btn-success btn-sm",null,""):""%>
						<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm",null,"onclick='showHistory()'")%>
				<%}%>
				<%=fb.button("btnConciliacion","Conciliación",false,false,"btn btn-inverse btn-sm|fa fa-print fa-lg",null,"onClick=\"javascript:printConciliacion()\"")%>
				<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-lg",null,"onClick=\"javascript:doPrint()\"")%>
		</td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimir-->
			 <%}%>

		<!--cuerpo del formulario aqui-->
		<!--el class de este sitio siempre debe tener el class="table table-small-font table-bordered table-striped"-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>
				<tr class="bg-headtabla">
				<%if(fg.trim().equalsIgnoreCase("history")){%>
					<th style="vertical-align: middle !important;">ADM</th>
				<%}%>
				<th style="vertical-align: middle !important;">Medicamento *</th>
				<th style="vertical-align: middle !important;">Concentracion</th>
				<th style="vertical-align: middle !important;">Forma</th>
				<th style="vertical-align: middle !important;">Frecuencia</th>
				<th style="vertical-align: middle !important;">Usuario</th>
				<th style="vertical-align: middle !important;" class="text-center">
				<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,"")%>
				</th>
				</tr>
				</thead>

				<tbody>

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
		<%=fb.hidden("recovered_adm"+i,cdo.getColValue("recovered_adm"))%>
		<%=fb.hidden("recovered_rn"+i,cdo.getColValue("recovered_rn"))%>
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("dosis"+i,cdo.getColValue("dosis"))%>
		<%=fb.hidden("forma"+i,cdo.getColValue("cod_grupo_dosis"))%>
		<%=fb.hidden("frecuencia"+i,cdo.getColValue("frecuencia"))%>
		<%=fb.hidden("via"+i,cdo.getColValue("via_admin"))%>
		<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		<%}else{%>
		<tr class="<%=color%>" align="center"  <%=style%>>
						<%if(fg.trim().equalsIgnoreCase("history")){%>
							<td><%=cdo.getColValue("admision"," ")%></td>
						<%}%>
			<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,flagModify,viewMode,20,"form-control input-md bg-warning",null,null)%></td>
			<td><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),false,false,viewMode,3,"form-control input-md",null,null)%></td>
			<td><%=fb.select("forma"+i,alDosis,cdo.getColValue("cod_grupo_dosis"),false,viewMode,0,"form-control input-md",null,null,"","S")%></td>
			<td><%=fb.textBox("frecuencia"+i,cdo.getColValue("frecuencia"),false,false,viewMode,12,"form-control input-md",null,null)%></td>
			<td>[<%=cdo.getColValue("user_ref_code"," ")%>]&nbsp;<%=cdo.getColValue("usuario_creac", (String) session.getAttribute("_userName"))%></td>
			<td>

						<%=fb.submit("rem"+i,"x",true,(cdo.getAction() != null && cdo.getAction().equals("U"))||viewMode,"btn btn-inverse btn-sm",null,"onclick=\"removeItem(this.form.name,"+i+")\"")%>


						</td>
		</tr>
				<tr class="<%=color%>" <%=style%>>
			<td colspan="2" valign="top">
				<cellbytelabel id="6">V&iacute;a de Administraci&oacute;n</cellbytelabel>
				<br>
				<%=fb.select("via"+i,alViaAd,cdo.getColValue("via_admin"),true,false,viewMode,0,"form-control input-md",null,null,"","S")%>
			</td>
			<td colspan="4">
				<cellbytelabel id="7"><strong>Observaciones</strong></cellbytelabel>
				<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,0,2000,"form-control input-md","width:100%","")%>
			</td>
		</tr>
		<%}%>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
				</tbody>
				</table>

				<%if(fg.trim().equals("")){%>
		<!--tabla de boton botones guardar cancelar-->
				<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
		</table>
		<!--tabla de boton botones guardar cancelar-->
		</div>
		<%}%>

		<%=fb.formEnd(true)%>
		</div>


		<!-- FIN contenido del sitio aqui-->
		</div>
		<!-- FIN contenido del sitio aqui-->
		<script>
				<%if (fg.trim().equalsIgnoreCase("history")){%>$("#loadingmsg").remove();<%}%>
		</script>
		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


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
			cdo.addColValue("user_ref_code", UserDet.getRefType());
			cdo.addColValue("recovered_adm",request.getParameter("recovered_adm"+i));
			cdo.addColValue("recovered_rn",request.getParameter("recovered_rn"+i));
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

				System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "+request.getParameter("remove"+i));

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
	} else if (baction.equalsIgnoreCase("recuperar")) {

		sbSql = new StringBuffer();
		sbSql.append("select 0 as renglon, nvl(z.descripcion,' ') as descripcion, nvl(z.dosis,' ') as dosis, nvl(z.observacion,' ') as observacion, decode(z.via_admin,null,' ',''||z.via_admin) as via_admin, decode(z.cod_grupo_dosis,null,' ',''||z.cod_grupo_dosis) as cod_grupo_dosis, nvl(z.cod_frecuencia,' ') as cod_frecuencia, decode(z.cada,null,' ',''||z.cada) as cada, nvl(z.tiempo,' ') as tiempo, nvl(z.frecuencia,' ') as frecuencia, admision as recovered_adm, renglon as recovered_rn from tbl_sal_antecedent_medicamento z where exists ( select null from ( ")
				.append("select pac_id, admision, count(*) as nrecs, row_number() over (order by admision desc) as rn from tbl_sal_antecedent_medicamento where pac_id = ")
				.append(request.getParameter("pacId"))
				.append(" and admision < ")
				.append(request.getParameter("noAdmision"))
				.append(" group by pac_id, admision having count(*) > 0")
			.append(" ) where rn = 1 and pac_id = z.pac_id and admision = z.admision")
			//control para no permitir recuperar los items ya recuperados
			.append(" and not exists ( select null from tbl_sal_antecedent_medicamento where pac_id = ")
				.append(request.getParameter("pacId"))
				.append(" and admision = ")
				.append(request.getParameter("noAdmision"))
				.append(" and recovered_rn = z.renglon )")
			.append(" )");
		al = SQLMgr.getDataList(sbSql.toString());
		for (int i=0; i<al.size(); i++) {
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("I");
			cdo.setKey(iAntMed.size() + 1);
			try {
				iAntMed.put(cdo.getKey(),cdo);
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>