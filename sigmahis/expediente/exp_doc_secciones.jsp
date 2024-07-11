<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DocumentosExp"%>
<%@ page import="issi.expediente.DetalleDocumentos"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="DCMgr" scope="session" class="issi.expediente.DocumentosCdsMgr" />
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCds" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSecc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSecc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProf" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProf" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSeccRes" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSeccRes" scope="session" class="java.util.Vector" />
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
DCMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
DocumentosExp doc = new DocumentosExp();
DetalleDocumentos detDoc = new DetalleDocumentos();
String sql = "";
String mode = "";
String tab = "";
String change = null;
String id = "";
String key = "";
int cdsLastLineNo = 0;
int seccLastLineNo = 0;
int profLastLineNo = 0;
int seccResLastLineNo = 0;
boolean viewMode = false;
String exp = "";

Hashtable ht = null;
String imagesFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

try {exp = java.util.ResourceBundle.getBundle("issi").getString("expediente.version");}catch(Exception e) {exp = "";}

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart")){
  ht = CmnMgr.getMultipartRequestParametersValue(request,imagesFolder,20,true);
  mode = (String)ht.get("mode");
  tab = (String)ht.get("tab");
  change = (String)ht.get("change");
  id = (String)ht.get("id");
  
  if ((String)ht.get("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt((String)ht.get("cdsLastLineNo"));
  if ((String)ht.get("seccLastLineNo") != null) seccLastLineNo = Integer.parseInt((String)ht.get("seccLastLineNo"));
  if ((String)ht.get("profLastLineNo") != null) profLastLineNo = Integer.parseInt((String)ht.get("profLastLineNo"));
  if ((String)ht.get("seccResLastLineNo") != null) seccResLastLineNo = Integer.parseInt((String)ht.get("seccResLastLineNo"));
  
}else{
	mode = request.getParameter("mode");
	tab = request.getParameter("tab");
	change = request.getParameter("change");
	id = request.getParameter("id");
	
	if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
	if (request.getParameter("seccLastLineNo") != null) seccLastLineNo = Integer.parseInt(request.getParameter("seccLastLineNo"));
	if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
	if (request.getParameter("seccResLastLineNo") != null) seccResLastLineNo = Integer.parseInt(request.getParameter("seccResLastLineNo"));
}

if (tab == null) tab = "0";
if (mode == null || mode == "") mode = "add";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
boolean forResume = false;


if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		if (change == null)
		{
			iCds.clear();
			vCds.clear();
			iSecc.clear();
			vSecc.clear();
			iProf.clear();
			vProf.clear();
			iSeccRes.clear();
			vSeccRes.clear();
		}//change is null
		doc.setForResume("N");
	}
	else
	{
		if (id == null) throw new Exception("El Documento Médico no es válido. Por favor intente nuevamente!");

		sql = "select id, description, name, status, disp_order dispOrder, decode(icon_path,null,' ','"+imagesFolder.replaceAll(rootFolder,"..")+"/'||icon_path) iconPath, for_resume as forResume from tbl_sal_exp_docs where id="+id;
		

		doc = (DocumentosExp) sbb.getSingleRowBean(ConMgr.getConnection(), sql, DocumentosExp.class);
		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "+doc.getDispOrder());
		
		forResume = (doc.getForResume()!=null&&doc.getForResume().equals("S"));

		if (change == null)
		{
			iCds.clear();
			vCds.clear();
			iSecc.clear();
			vSecc.clear();
			iProf.clear();
			vProf.clear();
			iSeccRes.clear();
			vSeccRes.clear();

			sql = "select a.doc_id as docId, a.cds_code as cdsCode, (select descripcion from tbl_cds_centro_servicio where codigo=a.cds_code) as CdsDesc from tbl_sal_exp_docs_cds a where a.doc_id="+id+" order by a.doc_id";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDocumentos.class);
			cdsLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DetalleDocumentos det = (DetalleDocumentos) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				try
				{
					iCds.put(det.getKey(), det);
					vCds.addElement(det.getCdsCode());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for

			sql = "select a.doc_id as docId, a.secc_code as seccCode, a.display_order as displayOrder, dis_order_flujo_aten displayOrderFlujoAten, (select descripcion from tbl_sal_expediente_secciones where codigo=a.secc_code) as seccDesc "+(exp.equals("3") ? ", nvl(req_para_cerrar,' ') as reqParaCerrar" : "")+" from tbl_sal_exp_docs_secc a where a.doc_id="+id+" order by a.display_order";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDocumentos.class);
			seccLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DetalleDocumentos det = (DetalleDocumentos) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				try
				{
					iSecc.put(det.getKey(), det);
					vSecc.addElement(det.getSeccCode());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for

			sql = "select a.doc_id as docId, a.profile_id as profileId, a.display_order as displayOrder, (select profile_name from tbl_sec_profiles where profile_id=a.profile_id) as profileName from tbl_sal_exp_docs_profile a where a.doc_id="+id+" order by 4";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDocumentos.class);
			profLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DetalleDocumentos det = (DetalleDocumentos) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				try
				{
					iProf.put(det.getKey(), det);
					vProf.addElement(det.getProfileId());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for
			
			
			
			if (forResume){
			
			   sql = "select a.documento_id as docResId, a.seccion_id as seccResId, a.orden as displayResOrder, a.ultimos_n_registros as ultimosNregistrosRes , a.ultimos_x_registros ultimosXregistrosRes, a.documento_desc as documentoResDesc, a.seccion_desc as seccionResDesc, a.estado as estadoRes, a.seccion_tabla as resSeccionTabla, a.tipo as resTipo, a.seccion_columnas as resSeccionColumnas, a.seccion_where_clause as resSeccionWhereClause, a.seccion_order_by as resSeccionOrderBy from tbl_sal_secciones_resumen a where a.documento_id = "+id+" order by a.orden";
				
				al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDocumentos.class);
				seccResLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					DetalleDocumentos det = (DetalleDocumentos) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					det.setKey(key);

					try
					{
						iSeccRes.put(det.getKey(), det);
						vSeccRes.addElement(id+"-"+det.getSeccResId());
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}//for
			
			} // for_resume

		}//change is null
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Documentos Secciones '+document.title;

function doAction()
{
<%
String tyype = "";
if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart")){
  tyype = (String)ht.get(request.getParameter("type"));
}else{
  tyype =request.getParameter("type");
}
if (tyype != null && !tyype.trim().equals(""))
{
	if (tab.equals("1"))
	{
%>
	showCdsList();
<%
	}
	else if (tab.equals("2"))
	{
%>
	showSectionList('documentos');
<%
	}
	else if (tab.equals("3"))
	{
%>
	showProfileList();
<%
	}
	else if (tab.equals("4"))
	{
%>
    showSectionList('secciones_resumen');
<%	
	}
}
%>
}

function showCdsList()
{
	abrir_ventana1('../common/check_cds.jsp?fp=documentos&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&seccLastLineNo=<%=seccLastLineNo%>&profLastLineNo=<%=profLastLineNo%>');
}

function showSectionList(fp)
{
	abrir_ventana1('../common/check_seccion.jsp?fp='+fp+'&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&seccLastLineNo=<%=seccLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&seccResLastLineNo=<%=seccResLastLineNo%>');
}

function showProfileList()
{
	abrir_ventana1('../common/check_profile.jsp?fp=documentos&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&seccLastLineNo=<%=seccLastLineNo%>&profLastLineNo=<%=profLastLineNo%>');
}

///////////////////////////////////////////
var inputsArray = new Array();
var countEmpty = 0;
	
function setInputsArray(){
   if (inputsArray.length > 0) inputsArray = new Array();
   if (countEmpty>0) countEmpty = 0;
   var n = parseInt("<%=iSecc.size()%>",10);
   for (i = 1; i <= n; i++){
     inputsArray[i-1] = document.getElementById("displayOrder"+i).value;
	 if (document.getElementById("displayOrder"+i).value=="" /*|| document.getElementById("displayOrderFlujoAten"+i).value==""*/){countEmpty++;}
   }	 
}

function hasDupes() {
    setInputsArray();
	var i, j, n;
	n = inputsArray.length;
	for (i = 0; i < n; i++) {
		for (j = i+1; j < n; j++) {
			if (inputsArray[i] != "") {
				if (inputsArray[i] == inputsArray[j]) {
				  //console.log("thebrain: inputsArray[i] = "+i);
				  //console.log("thebrain: inputsArray[j] = "+j);
				  setXtraInfo("Las filas "+(i+1)+" y "+(j+1)+" son duplicadas");
				  return true;
				}
            }
        }
    }
    return false;
}

function setXtraInfo(info){document.getElementById("xtraInfo").value=info;}
function getXtraInfo(){return document.getElementById("xtraInfo").value;}

function doSubmit(fName){
   //console.log("thebrain: countEmpty = "+countEmpty);
   var canProceedToSubmit = false;
   var msg = "";
   
   if (hasDupes()){canProceedToSubmit = false; msg ="Usted esta tratando de guardar valores duplicados en el campo: Orden\n"+getXtraInfo();}
   else if (countEmpty > 0 ){canProceedToSubmit = false; msg = "No puede dejar las órdenes en blanco!";}
   else canProceedToSubmit = true;
   
   if (canProceedToSubmit){document.forms[fName].submit();}else{CBMSG.error(msg);}
}
function showAdmClasif(){
  abrir_ventana("../common/check_clasificacion_adm.jsp?fp=exp_doc&tipoPoliza=&tipoPlan=&planNo=");
}

$(document).ready(function(){
  $("#save0").click(function(){
    var _proceed = true;
	var mode = "<%=mode%>";

	if ($("#for_resume").val() == "S"){
	
		var forResume = splitCols(getDBData('<%=request.getContextPath()%>',"id||' - '||name",'tbl_sal_exp_docs',"for_resume='S'",''));
		
		if (forResume){
		   if (mode=="edit") {
		     var isCurForResume = getDBData('<%=request.getContextPath()%>',"count(*)",'tbl_sal_exp_docs',"for_resume='S' and id = <%=id%>",'');
			 if (parseInt(isCurForResume,10)) _proceed = true;
			 else  _proceed = false;
		   }
		   else _proceed = false;
		   
		   if (!_proceed) CBMSG.error("El documento ***"+forResume[0]+"*** ya está definido para ser resumen del estado actual del paciente!");
		}
	}
	if ( $("#icon_path").isAValidImg() && _proceed ) $("#form0").submit();
  });
  
  $("#save4").click(function(){
     var s = parseInt("<%=iSeccRes.size()%>");
	 var _proceed = true;
	 for (i = 1; i<=s; i++){
	   var uNr = $("#ultimosNregistros"+i).val() || 0;
	   var uXr = $("#ultimosXregistros"+i).val() || 0;
	   var displayResOrder = $("#displayResOrder"+i).val() || 0;
	   if (uNr==0 && uXr==0){
		_proceed = false;
		CBMSG.error("No puede llenar los dos campo al mismo tiempo!");
		$("#ultimosNregistros"+i).select();
		break;
	   }else if ( !isInteger(displayResOrder) ){
	     _proceed = false;
	     CBMSG.error("No se permite valores no numéricos en el campo 'Orden' !");
		 break;
	   }
	 }
	 
	 if (_proceed) $("#form4").submit();
  });
  
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
<jsp:param name="title" value='DOCUMENTOS SECCIONES'></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">

<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1">

<%//fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null, FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("seccSize",""+iSecc.size())%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("secResSize",""+iSeccRes.size())%>

		<tr class="TextRow02">
			<td colspan="4" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel>Secuencia</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("id",doc.getId(),false,false,true,5)%>
			<span style="text-align:right">
			&nbsp;&nbsp;&nbsp;&nbsp;Orden:<%=fb.textBox("disp_order",doc.getDispOrder(),false,false,false,5,3,null,null,"")%>
			</span>
			</td>
			<td width="15%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",doc.getName(),true,false,viewMode,50)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",doc.getStatus(),false,viewMode,0)%></td>
			<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("desc",doc.getDescription(),false,false,viewMode,50)%></td>
		</tr>
		
		<tr class="TextRow01">
			<td><cellbytelabel>Icono</cellbytelabel></td>
			<td><%=fb.fileBox("icon_path", doc.getIconPath(),false,false,16)%></td>
			<td><cellbytelabel>Estado actual del paciente?</cellbytelabel></td>
			<td><%=fb.select("for_resume","S=SI,N=NO",doc.getForResume(),false,viewMode,0)%></td>
		</tr>
	
		<tr class="TextRow02">
			<td colspan="4" align="right">
			<%String fName = "'"+fb.getFormName()+"'"; %>
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.button("save0","Guardar",true,viewMode,null,null,"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1" >

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("seccSize",""+iSecc.size())%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("secResSize",""+iSeccRes.size())%>

<%fName = "'"+fb.getFormName()+"'"; %>

		<tr class="TextRow02">
			<td colspan="3" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><cellbytelabel id="9">Documento:</cellbytelabel> [<%=doc.getId()%>] <%=doc.getName()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
			<td width="75%"><cellbytelabel id="11">Centro de servicio</cellbytelabel></td>
			<td width="5%"><%=fb.submit("addCds","+",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value)\"","Agregar Centro de Servicios")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iCds);
for (int i=1; i<=iCds.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleDocumentos det = (DetalleDocumentos) iCds.get(key);
%>
		<%=fb.hidden("key"+i,""+key)%>
		<%=fb.hidden("cdsCode"+i,det.getCdsCode())%>
		<%=fb.hidden("cdsDesc"+i,det.getCdsDesc())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td align="center"><%=det.getCdsCode()%></td>
			<td><%=det.getCdsDesc()%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem("+fName+","+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="3" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="6">Crear Otro</cellbytelabel> -->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("seccSize",""+iSecc.size())%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("xtraInfo","")%>
<%=fb.hidden("hasEmpty","0")%>
<%=fb.hidden("secResSize",""+iSeccRes.size())%>

<%fName = "'"+fb.getFormName()+"'"; %>

		<tr class="TextRow02">
			<td colspan="5" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="5"><cellbytelabel id="9">Documento</cellbytelabel>: [<%=doc.getId()%>] <%=doc.getName()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
			<td width="45%"><cellbytelabel id="12">Secci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Orden</cellbytelabel></td>
			<!--<td width="20%"><cellbytelabel id="14">Orden Flujo Atenci&oacute;n</cellbytelabel></td>-->
			<%if(exp.equals("3")){%>
        <td width="20%"><cellbytelabel id="14">Requerido para cerrar el EXP.</cellbytelabel></td>
			<%}%>
			<td width="5%"><%=fb.submit("addSection","+",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value)\"","Agregar Secciones")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iSecc);
for (int i=1; i<=iSecc.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleDocumentos det = (DetalleDocumentos) iSecc.get(key);
%>
		<%=fb.hidden("key"+i,""+key)%>
		<%=fb.hidden("seccCode"+i,det.getSeccCode())%>
		<%=fb.hidden("seccDesc"+i,det.getSeccDesc())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td align="center"><%=det.getSeccCode()%></td>
			<td><%=det.getSeccDesc()%> </td>
			<td align="center"><%=fb.intBox("displayOrder"+i,det.getDisplayOrder(),true,false,false,5,null,null,"")%></td>
			<!--<td align="center"><%//=fb.intBox("displayOrderFlujoAten"+i,det.getDisplayOrderFlujoAten(),true,false,false,5)%></td>-->
			<%if(exp.equals("3")){%>
        <td align="center">
          <input type="checkbox" name="req_para_cerrar<%=i%>" id="req_para_cerrar<%=i%>" <%=det.getReqParaCerrar()!=null&&det.getReqParaCerrar().equalsIgnoreCase("Y") ? " checked" : ""%> value="Y">
        </td>
			<%}%>
			<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem("+fName+","+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="5" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="6">Crear Otro</cellbytelabel>-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value); doSubmit("+fName+")\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB2 DIV END HERE-->
</div>

<!-- TAB3 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cdsSize",""+iCds.size())%>
<%=fb.hidden("seccSize",""+iSecc.size())%>
<%=fb.hidden("profSize",""+iProf.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("secResSize",""+iSeccRes.size())%>

		<tr class="TextRow02">
			<td colspan="4" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4"><cellbytelabel id="9">Documento</cellbytelabel>: [<%=doc.getId()%>] <%=doc.getName()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
			<td width="65%"><cellbytelabel id="14">Perfil</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Orden</cellbytelabel></td>
			<td width="5%"><%=fb.submit("addProfile","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Perfiles")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iProf);
for (int i=1; i<=iProf.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleDocumentos det = (DetalleDocumentos) iProf.get(key);
%>
		<%=fb.hidden("key"+i,""+key)%>
		<%=fb.hidden("profileId"+i,det.getProfileId())%>
		<%=fb.hidden("profileName"+i,det.getProfileName())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td align="center"><%=det.getProfileId()%></td>
			<td><%=det.getProfileName()%></td>
			<td align="center"><%=fb.intBox("displayOrder"+i,det.getDisplayOrder(),true,false,false,5)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="6">Crear Otro</cellbytelabel>-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

<%=fb.formEnd(true)%>

		</table>

<!-- TAB3 DIV END HERE-->
</div>


<!-- TAB4 DIV BEFINS HERE-->
<div class = "dhtmlgoodies_aTab">
    <table align="center" width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab","4")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("cdsSize",""+iCds.size())%>
		<%=fb.hidden("seccSize",""+iSecc.size())%>
		<%=fb.hidden("profSize",""+iProf.size())%>
		<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
		<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
		<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
		<%=fb.hidden("seccResLastLineNo",""+seccResLastLineNo)%>
		<%=fb.hidden("secResSize",""+iSeccRes.size())%>
		<%=fb.hidden("documento_desc",doc.getName())%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("xtraInfo","")%>
		<%=fb.hidden("hasEmpty","0")%>

		<%fName = "'"+fb.getFormName()+"'"; %>

		<tr class="TextRow02">
			<td colspan="12" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="12"><cellbytelabel id="9">Documento</cellbytelabel>: [<%=doc.getId()%>] <%=doc.getName()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="3%"><cellbytelabel>C&oacute;d.</cellbytelabel></td>
			<td width="17%" align="left"><cellbytelabel>Secci&oacute;n</cellbytelabel></td>
			<td width="17%"><cellbytelabel>Tabla</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Tipo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="5%"><cellbytelabel>&Uacute;lt. N reg.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>&Uacute;lt. X reg.</cellbytelabel></td>
			<td width="13%" align="left"><cellbytelabel>Columnas</cellbytelabel></td>
			<td width="12%" align="left"><cellbytelabel>Where Clause</cellbytelabel></td>
			<td width="10%" align="left"><cellbytelabel>Order By</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="3%"><%=fb.submit("addSection","+",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value)\"","Agregar Secciones")%></td>
		</tr>
		<%
		al = CmnMgr.reverseRecords(iSeccRes);
		for (int i=1; i<=iSeccRes.size(); i++)
		{
			key = al.get(i - 1).toString();
			DetalleDocumentos det = (DetalleDocumentos) iSeccRes.get(key);
		%>
			<%=fb.hidden("key"+i,""+key)%>
			<%=fb.hidden("seccCode"+i,det.getSeccResId())%>
			<%=fb.hidden("remove"+i,"")%>
			<tr class="TextRow01">
				<td align="center"><%=det.getSeccResId()%></td>
				<td><%=fb.textBox("seccDesc"+i,det.getSeccionResDesc(),false,false,false,30,null,null,"")%></td>
				<td><%=fb.textBox("seccion_tabla"+i,det.getResSeccionTabla(),false,false,false,32,null,null,"")%></td>
				<td align="center"><%=fb.select("tipo"+i,"C=Gráfica,P=Texto Plano",det.getResTipo(),false,viewMode,0,null,"width:50px",null)%></td>
				<td align="center"><%=fb.intBox("displayResOrder"+i,det.getDisplayResOrder(),true,false,false,5,null,null,"")%></td>
				<td align="center"><%=fb.textBox("ultimosNregistros"+i,det.getUltimosNregistrosRes(),false,false,false,5,2,"ignore",null,null)%></td>
				<td align="center"><%=fb.textBox("ultimosXregistros"+i,det.getUltimosXregistrosRes(),false,false,false,5,8,"ignore",null,null)%></td>
				
				<td><%=fb.textBox("seccion_columnas"+i,det.getResSeccionColumnas(),false,false,false,22,"ignore",null,null)%></td>
				<td><%=fb.textBox("seccion_where_clause"+i,det.getResSeccionWhereClause(),false,false,false,20,"ignore",null,null)%></td>
				<td><%=fb.textBox("order_by"+i,det.getResSeccionOrderBy(),false,false,false,16,null,null,null)%></td>
				<td align="center"><%=fb.select("status"+i,"A=ACTIVO,I=INACTIVO",det.getEstadoRes(),false,viewMode,0,null,"width:50px",null)%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem("+fName+","+i+")\"","Eliminar")%></td>
			</tr>
		<%}%>
		<tr class="TextRow02">
			<td colspan="12" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.button("save4","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction("+fName+",this.value);\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>

		<%=fb.formEnd(true)%>
	</table>
</div>
<!-- TAB4 DIV ENDS HERE-->


<!-- MAIN DIV END HERE -->
</div>

	</td>
</tr>
</table>
<script type="text/javascript">
<%
String tabLabel = "'Documento'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Centro de Servicios','Secciones','Perfiles'";
if(forResume && !mode.equalsIgnoreCase("add")) tabLabel += ",'Secciones - Condición Paciente'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	doc = new DocumentosExp();
	doc.setId(id);
	if (tab.equals("0"))//Documento
	{
		saveOption = (String)ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
		baction = (String)ht.get("baction");
		
		doc.setName((String)ht.get("name"));
		doc.setDescription((String)ht.get("desc"));
		doc.setStatus((String)ht.get("status"));
		doc.setIconPath((String)ht.get("icon_path"));
		doc.setDispOrder((String)ht.get("disp_order"));
		doc.setForResume((String)ht.get("for_resume"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			DCMgr.add(doc);
			id = DCMgr.getPkColValue("id");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			DCMgr.update(doc);
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1"))//Centro de Servicio
	{
		String itemRemoved = "";
		int size = Integer.parseInt(request.getParameter("cdsSize"));

		doc.getCds().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleDocumentos det = new DetalleDocumentos();

			det.setCdsCode(request.getParameter("cdsCode"+i));
			det.setCdsDesc(request.getParameter("cdsDesc"+i));
			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = det.getKey();
			else
			{
				try
				{
					iCds.put(det.getKey(),det);
					doc.addCds(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			vCds.remove(((DetalleDocumentos) iCds.get(itemRemoved)).getCdsCode());
			iCds.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			DCMgr.addCds(doc);
			ConMgr.clearAppCtx(null);
		}
	}//Centro de Servicio
	else if (tab.equals("2"))//Seccion
	{
		String itemRemoved = "";
		int size = Integer.parseInt(request.getParameter("seccSize"));

		doc.getSection().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleDocumentos det = new DetalleDocumentos();

			det.setSeccCode(request.getParameter("seccCode"+i));
			det.setSeccDesc(request.getParameter("seccDesc"+i));
			det.setDisplayOrder(request.getParameter("displayOrder"+i));
			//det.setDisplayOrderFlujoAten(request.getParameter("displayOrderFlujoAten"+i));
			if (exp.equals("3")) det.setReqParaCerrar(request.getParameter("req_para_cerrar"+i));
			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = det.getKey();
			else
			{
				try
				{
					iSecc.put(det.getKey(),det);
					doc.addSection(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			vSecc.remove(((DetalleDocumentos) iSecc.get(itemRemoved)).getSeccCode());
			iSecc.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			DCMgr.addSection(doc);
			ConMgr.clearAppCtx(null);
		}
	}//Seccion
	else if (tab.equals("3"))//Perfil
	{
		String itemRemoved = "";
		int size = Integer.parseInt(request.getParameter("profSize"));

		doc.getProfile().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleDocumentos det = new DetalleDocumentos();

			det.setProfileId(request.getParameter("profileId"+i));
			det.setProfileName(request.getParameter("profileName"+i));
			det.setDisplayOrder(request.getParameter("displayOrder"+i));
			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = det.getKey();
			else
			{
				try
				{
					iProf.put(det.getKey(),det);
					doc.addProfile(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			vProf.remove(((DetalleDocumentos) iProf.get(itemRemoved)).getProfileId());
			iProf.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			DCMgr.addProfile(doc);
			ConMgr.clearAppCtx(null);
		}
	}//Perfil
	else if (tab.equals("4"))//Seccion
	{
		String itemRemoved = "";
		int size = Integer.parseInt(request.getParameter("secResSize"));

		doc.getSectionRes().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleDocumentos det = new DetalleDocumentos();

			det.setSeccResId(request.getParameter("seccCode"+i));
			det.setSeccionResDesc(request.getParameter("seccDesc"+i));
			det.setDocumentoResDescRes(request.getParameter("documento_desc"));
			det.setDisplayResOrder(request.getParameter("displayResOrder"+i));
			det.setUltimosNregistrosRes(request.getParameter("ultimosNregistros"+i));
			det.setUltimosXregistrosRes(request.getParameter("ultimosXregistros"+i));
			det.setEstadoRes(request.getParameter("status"+i));
			det.setResSeccionTabla(request.getParameter("seccion_tabla"+i));
			det.setResTipo(request.getParameter("tipo"+i));
			det.setResSeccionColumnas(request.getParameter("seccion_columnas"+i));
			det.setResSeccionWhereClause(request.getParameter("seccion_where_clause"+i));
			det.setResSeccionOrderBy(request.getParameter("order_by"+i));
			det.setKey(request.getParameter("key"+i));
			
			System.out.println("ultimosNregistros------------------------------------------- "+det.getUltimosNregistrosRes());
			System.out.println("ultimosXregistros------------------------------------------- "+det.getUltimosXregistrosRes());
			
			String _removeKey = id+"-"+request.getParameter("seccCode"+i);

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = det.getKey();
			else
			{
				try
				{
					iSeccRes.put(det.getKey(),det);
					doc.addSectionRes(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			vSeccRes.remove(id+"-"+((DetalleDocumentos) iSeccRes.get(itemRemoved)).getSeccResId());
			iSeccRes.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo+"&seccResLastLineNo="+seccResLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&profLastLineNo="+profLastLineNo+"&seccResLastLineNo="+seccResLastLineNo);
			return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			DCMgr.addSectionRes(doc);
			ConMgr.clearAppCtx(null);
		}
	}//Seccion
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (DCMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DCMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_documentos_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_documentos_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/exp_documentos_list.jsp';
<%
	}
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
} else throw new Exception(DCMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?&mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
