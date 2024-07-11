<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Escalas"%>
<%@ page import="issi.expediente.DetalleEscala"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaMgr" />
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
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Escalas escala = new Escalas();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

Vector v1 =null;
Vector v2 = null;

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String tmpTot = request.getParameter("tmpTot")==null?"0":request.getParameter("tmpTot");
String forceSumEval = request.getParameter("forceSumEval")==null?"0":request.getParameter("forceSumEval");
int iconHeight = 48;
int iconWidth = 48;

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "WB";
if (desc == null) desc = "";
if (forceSumEval == null) forceSumEval = "";

boolean checkDefault = false;
int rowCount = 0;
String fecha_eval = request.getParameter("fecha_eval");
String hora_eval = request.getParameter("hora_eval");
int escLastLineNo = 0;
String appendFilter="" , op = "";
String key = "",titulo="";
String eTotal=request.getParameter("eTotal")==null?"0":request.getParameter("eTotal");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if(fg.trim().equals("WB")) titulo ="ESCALA WONG BAKER ";
else if(fg.trim().equals("MO")) titulo ="ESCALA DE MORSE ";
else if(fg.trim().equals("CR")) titulo ="ESCALA CRIES";
else if(fg.trim().equals("NI")) titulo ="ESCALA NIPS";
else if(fg.trim().equals("AN")) titulo ="ESCALA ANALOGA";
else titulo ="ESCALA DE DOLOR ";

CommonDataObject cdoInt = new CommonDataObject();
boolean showInterv = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql="select to_char(se.fecha,'dd/mm/yyyy') as fecha, to_char(se.hora,'hh12:mi:ss am') as hora , se.total ,se.id,se.usuario_mod usuarioMod, to_char(se.fecha_mod,'dd/mm/yyyy')fechaMod, to_char(se.fecha_mod,'hh12:mi:ss am')horaMod,se.usuario from tbl_sal_escalas se  where se.pac_id = "+pacId+" and se.admision = "+noAdmision+" and se.tipo ='"+fg+"' order by to_date(se.fecha||' '||to_char(se.hora,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc";
al2= SQLMgr.getDataList(sql);

String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (expVersion.equals("2")) {
	cdoInt = SQLMgr.getData("select habilitar_intervencion from tbl_sal_concepto_norton where tipo = '"+fg+"' and rownum = 1");
	if (cdoInt == null) cdoInt = new CommonDataObject();
	showInterv = cdoInt.getColValue("habilitar_intervencion","N").equalsIgnoreCase("Y");
}

if(!fg.trim().equals("MO"))
{
	sql = "select codigo, descripcion from tbl_sal_dolor where estado ='A' and (tipo = '"+fg+"' or tipo = 'AN') order by codigo";
	al3= SQLMgr.getDataList(sql);

	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'ME' order by  tipo desc";
	al4= SQLMgr.getDataList(sql);
	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'NF' order by  tipo desc";
	al5= SQLMgr.getDataList(sql);
}

if(!id.trim().equals("0"))
{
			sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, observacion,total,dolor,intervencion,localizacion from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id+" and tipo ='"+fg+"'";

		escala = (Escalas) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Escalas.class);
		System.out.println("SQL = "+sql);
		if (!viewMode) modeSec = "edit";



}else //if(escala == null)
		{
				escala = new Escalas();
				escala.setHora(cDateTime.substring(11));
				escala.setFecha(cDateTime.substring(0,10));
				escala.setDolor("");
				escala.setIntervencion("");
				escala.setTotal("0");
				if (!viewMode) modeSec = "add";

		}
if(!fg.trim().equals("MO"))
{
	v1 = CmnMgr.str2vector(escala.getDolor(),"|");
	v2 = CmnMgr.str2vector(escala.getIntervencion(),"|");
}
//sql=" select nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM tbl_sal_concepto_norton a, ( select nvl(cod_escala ,0)as tipo_escala, nvl(detalle,0)as detalle, OBSERVACION, VALOR, APLICAR FROM tbl_sal_detalle_esc  where id ="+id+" and tipo ='"+fg+"' order by 1,2 ) b where a.codigo=b.tipo_escala(+)  and a.tipo='"+fg+"'    union SELECT a.codigo,a.secuencia, 0, a.descripcion, a.valor,null,0, '' from tbl_sal_det_concepto_norton a, ( select nvl(cod_escala,0) as tipo_escala  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo ='"+fg+"' ORDER BY 1,2 ";

	sql="select nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM tbl_sal_concepto_norton a, ( select nvl(cod_escala ,0)as tipo_escala, nvl(detalle,0)as detalle, OBSERVACION, VALOR, APLICAR FROM tbl_sal_detalle_esc  where id ="+id+" and tipo = '"+fg+"' order by 1,2 ) b where a.codigo=b.tipo_escala(+)  and a.tipo='"+fg+"' and a.estado='A'  union select a.codigo,a.secuencia, 0, a.descripcion, a.valor,null,0, '' from tbl_sal_det_concepto_norton a,tbl_sal_concepto_norton c,  ( select nvl(cod_escala,0) as tipo_escala  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo = '"+fg+"' and a.estado='A' and c.codigo =a.codigo(+) and a.estado(+)=c.estado ORDER BY 1,2 ";
	 al = SQLMgr.getDataList(sql);
	 
String showRiesgo = "SIN PRECAUCION";
try{showRiesgo=java.util.ResourceBundle.getBundle("issi").getString("showRiesgo");}catch(Exception e){}
if (showRiesgo.equals("Y")) showRiesgo = "SIN RIESGO";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'ESCALAS - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verEscala(k,mode){var fecha = eval('document.form0.fecha'+k).value ;var hora = eval('document.form0.hora'+k).value ;
var cTot = eval('document.form0.total_tmp'+k).value ;
var mode ='view'; //(fecha=='<%=cDateTime.substring(0,10)%>')?'edit':'view';
var id = eval('document.form0.code'+k).value;var tmpTot=$("#temp_total"+k).val();window.location = '../expediente/exp_escalas_dolor.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+id+'&fg=<%=fg%>&desc=<%=desc%>&tmpTot='+tmpTot+'&eTotal='+cTot;}
function add(){window.location = '../expediente/exp_escalas_dolor.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&fg=<%=fg%>&desc=<%=desc%>';}
function doAction(){setHeight();checkViewMode();}
function setHeight(){newHeight();}
function setEscalaValor(k,codigo,valor){sumaEscala();}
function distValor(j){var size1 = parseInt(document.getElementById("size").value);for (i=1;i<=size1;i++){if(i!=j)document.getElementById("escala"+i).checked = false;}eval('document.form0.opcion').value = "1";}
function setAlert(){alert('No se ha realizado la evaluación');}
function consultar(){abrir_ventana1('../expediente/list_evaluacion_dolor.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');}
function ayuda(){abrir_ventana1('../expediente/Escala_morse.pdf');}
function imprimir(){ var total = $("#total2").val()||0; abrir_ventana1('../expediente/print_exp_seccion_80.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=modeSec%>&fg=<%=fg%>&seccion=<%=seccion%>&id=<%=id%>&desc=<%=desc%>&total='+total);}

function sumaEscala(val){
	var total = 0;
	for (i=1;i<=parseInt(document.getElementById("size").value);i++){
		var chk = eval('document.form0.escala'+i).length;
		
		if (parseInt(val,10)) total = val;
		else{
			for (k=0;k<chk;k++){
				if(eval('document.form0.escala'+i)[k].checked){
					total = total + parseInt(eval('document.form0.valorCH'+i+k).value);
					eval('document.form0.valor'+i).value = eval('document.form0.valorCH'+i+k).value;
					eval('document.form0.codDetalle'+i).value = eval('document.form0.codDetalle'+i+k).value;
				}
			}
		}
	}
	document.getElementById("total2").value = total;eval('document.form0.valIni').value = "1";
	<%if(fg.trim().equals("MO")){%>
		if (total >= 0 &&total<=24){
			document.getElementById("clasificacion").style.color='green';
			document.getElementById("clasificacion").innerHTML='<%=showRiesgo%>';
		}else if (total>=25&&total<=50){
			document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';
		}else if (total>=50){
			document.getElementById("clasificacion").style.color='red';document.getElementById("clasificacion").innerHTML='ALTO RIESGO';
		}
	<%}%>
}

$(function(){
   $("#__intervencion").click(function(e){
       var total = $("#total2").val()||0;
	   parent.showPopWin('../expediente/exp_intervencion_list.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&total='+total,winWidth*.85,winHeight*.75,null,null,'');
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
			<%=fb.hidden("opcion","0")%>
			<%=fb.hidden("valIni","0")%>
			<%=fb.hidden("fg",""+fg)%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("sizeD",""+al3.size())%>
			<%=fb.hidden("sizeIM",""+al4.size())%>
			<%=fb.hidden("sizeNF",""+al5.size())%>
			<%=fb.hidden("desc",desc)%>
			<tr>
					<td  colspan="6"  style="text-decoration:none;">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" class="child">
					 	<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextRow02">
			            <td colspan="6" align="right">&nbsp;</td>
		                </tr>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel>Listado de Evaluaciones [ Escala ]</cellbytelabel></td>
							<td align="right" colspan="3"><%if(fg.trim().equals("MO")){%><a href="javascript:ayuda()" class="Link00">[ Ayuda ]</a><%}%>
<a href="javascript:consultar()" class="Link00">[ <cellbytelabel>Consultar</cellbytelabel> ]</a>&nbsp;<%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ Agregar ]</a><%}%>&nbsp;<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></td>
						</tr>
						<tr class="TextHeader" align="center">
								<td width="15%"><cellbytelabel>Fecha</cellbytelabel></td>
								<td width="15%"><cellbytelabel>Hora</cellbytelabel></td>
								<td width="15%"><cellbytelabel>Total</cellbytelabel></td>
								<td width="15%"><cellbytelabel>Creado Por</cellbytelabel></td>
								<td width="15%"><cellbytelabel>Modif. por</cellbytelabel></td>
								<td width="20%"><cellbytelabel>Fecha/Hora Mod</cellbytelabel>.</td>
							</tr>

<%
for (int i=1; i<=al2.size(); i++)
{
	cdo = (CommonDataObject) al2.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("code"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
		<%=fb.hidden("temp_total"+i,cdo.getColValue("total"))%>
		<%=fb.hidden("total_tmp"+i,cdo.getColValue("total"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEscala(<%=i%>,'view')" align="center">
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("hora")%></td>
				<td align="center"><%=cdo.getColValue("total")%></td>
				<td><%=cdo.getColValue("usuario")%></td>
				<td><%=cdo.getColValue("usuarioMod")%></td>
				<td><%=cdo.getColValue("fechaMod")%>/<%=cdo.getColValue("horaMod")%></td>
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
					<tr>
						<td width="25%"><cellbytelabel>Fecha</cellbytelabel>:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=escala.getFecha()%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							</jsp:include></td>
						<td width="25%"><cellbytelabel>Hora</cellbytelabel>:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="hh12:mi:ss am"/>
							<jsp:param name="nameOfTBox1" value="hora" />
							<jsp:param name="valueOfTBox1" value="<%=escala.getHora()%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							</jsp:include></td>
						<td width="15%" nowrap>&nbsp;</td>
						<td nowrap>&nbsp;</td>
					</tr>
				</table>
				</td>
			</tr>
			<%if(showInterv){%>
			<%if(!fg.trim().equals("MO") && !fg.trim().equals("DO") && !fg.trim().equals("RAM")){%>
			<tr class="TextHeader">
							<td colspan="3"><cellbytelabel>Descripci&oacute;n de los C&oacute;digos</cellbytelabel> </td>
			</tr>
			<tr class="TextRow02">
				<td valign="top">
					<table border="0" cellpadding="0" cellspacing="0" class="TextRow02" width="100%">
						<tr class="TextHeader" align="center">
							<td width="10%">&nbsp;</td>
							<td width="90%"><cellbytelabel>Descripci&oacute;n Del Dolor</cellbytelabel></td>
						</tr>
<%
for (int i=1; i<=al3.size(); i++)
{
	cdo = (CommonDataObject) al3.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("idD"+i,cdo.getColValue("codigo"))%>

		<tr class="<%=color%>" valign="top">
				<td><%=fb.checkbox("aplicarD"+i,"S",(CmnMgr.vectorContains(v1,cdo.getColValue("codigo"))),viewMode,null,null,"")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
		</tr>
<%
}
%>

					</table>
				</td>
				<td valign="top">
					<table border="0" cellpadding="0" cellspacing="0" class="TextRow02"  width="100%">
						<tr class="TextHeader" align="center">
							<td width="10%">&nbsp;</td>
							<td width="90%"><cellbytelabel>Intervenci&oacute;n M&eacute;dica</cellbytelabel></td>
						</tr>
						<%
for (int i=1; i<=al4.size(); i++)
{
	cdo = (CommonDataObject) al4.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("idMe"+i,cdo.getColValue("codigo"))%>

		<tr class="<%=color%>" valign="top" bgcolor="#FF3399">
				<td><%=fb.checkbox("aplicarMe"+i,"S",(CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))),viewMode,null,null,"")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
		</tr>
<%
}
%>

					</table>
				</td>
				<td valign="top">
					<table border="0" cellpadding="0" cellspacing="0" class="TextRow02"  width="100%">
						<tr class="TextHeader" align="center">
							<td width="10%">&nbsp;</td>
							<td width="90%"><cellbytelabel>Intervenci&oacute;n No-Farmacol&oacute;gica</cellbytelabel></td>
						</tr>
<%
for (int i=1; i<=al5.size(); i++)
{
	cdo = (CommonDataObject) al5.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>
		<%=fb.hidden("idNf"+i,cdo.getColValue("codigo"))%>
		<tr class="<%=color%>" valign="top">
				<td><%=fb.checkbox("aplicarNf"+i,"S",(CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))),viewMode,null,null,"")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
		</tr>
<%
}
%>


					</table>
				</td>
			</tr>
			<tr class="TextRow01">
				<td align="right"><cellbytelabel>Localizaci&oacute;n del dolor</cellbytelabel></td>
				<td colspan="2"><%=fb.textarea("localizacion",escala.getLocalizacion(),false,false,viewMode,40,2,2000,null,"",null)%></td>
			</tr>
			<%}else{%>
				<%if(!fg.equalsIgnoreCase("RAM")){%>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Intervenci&oacute;n</cellbytelabel></td>
					<td colspan="2"><%=fb.textarea("intervencion",escala.getIntervencion(),false,false,viewMode,40,2,2000,null,"",null)%></td>
				</tr>
				<%}%>
			<%}%>
			<%}%>
			<tr class="TextHeader">
				<td colspan="2"><cellbytelabel>Evaluaci&oacute;n</cellbytelabel> </td>
				<td align="right"><%if(!fg.equalsIgnoreCase("RAM")){%><span class="Link04Bold pointer" data-fg="<%=fg%>" id="__intervencion"><cellbytelabel>Intervenciones</cellbytelabel></span><%}else{%>&nbsp;<%}%></td>
			</tr>
			<tr class="TextHeader" align="center">
				<td width="20%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width="20%"><cellbytelabel>Escala</cellbytelabel></td>
				<td width="25%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
			</tr>
			<!---<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right">Total:<%//=fb.intBox("total2",""+eTotal+"",false,false,true,2)%></td>
				<td><b><label id="clasificacion" style="color:green">HOLA</label></b></td>
				</tr>-->
				
<%
		int lc=0 ,De=0 ;
		String codE = "", observ = "";
		String codAnt = "";//al = CmnMgr.reverseRecords(HashDet);
		String detalleCod = "";
		boolean codDetSig = false;
		for (int i = 0; i <al.size(); i++)
		{
			key = al.get(i).toString();
			cdo = (CommonDataObject) al.get(i);
			codE = cdo.getColValue("codigo");

			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
if(cdo.getColValue("cod_escala").equals("0"))
{
			De=0;
			lc++;
			detalleCod = cdo.getColValue("detalle");
			observ = cdo.getColValue("observacion");
			if(cdo.getColValue("detalle").equals("0") && !viewMode )
			{
						codDetSig = true;
			}
%>
			<%=fb.hidden("cod_escala"+lc,cdo.getColValue("codigo"))%>
			<%=fb.hidden("codDetalle"+lc,"0")%>
			<%=fb.hidden("valor"+lc,"0")%>

			<tr class="<%=color%>">
							<td align="left" width="34%"><%=cdo.getColValue("descripcion")%></td>
					<td width="33%">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="<%=color%>">
<%}
else if(!cdo.getColValue("cod_escala").equals("0"))
{
%>
					<%=fb.hidden("valorCH"+lc+De,cdo.getColValue("escala"))%>
					<%=fb.hidden("codDetalle"+lc+De,cdo.getColValue("cod_escala"))%>
					<tr class="<%=color%>">
							<td width="5%" valign="middle" ><!---codDetSig ||--para que el primer check este seleccionado-->
							<%=fb.radio("escala"+lc, cdo.getColValue("cod_escala"),(detalleCod.equals(cdo.getColValue("cod_escala"))|| codDetSig ),viewMode, false , "", "", "onClick=\"javascript:setEscalaValor('"+lc+"','"+cdo.getColValue("cod_escala")+"','"+cdo.getColValue("escala")+"')  \" ")%>						</td>
										<td width="75%" valign="middle"><%=cdo.getColValue("descripcion")%></td>
										<%if(fg.trim().equals("WB")){%><td width="10%" valign="middle"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/dolor<%=cdo.getColValue("cod_escala")%>.gif"> </td><%}%>
										<td width="10%" align="right" valign="middle"><%=cdo.getColValue("escala")%></td>
									</tr>
								<%

						codDetSig=false;
						if(i<al.size()-1)
						{
							 cdo = (CommonDataObject) al.get(i+1);
							 codAnt = cdo.getColValue("codigo");
						}
						else
						{%>
						</table>
							</td>
							<td width="33%"><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,50,3,2000,null,"width='100%'",null)%></td>
								</tr>
							<%
							detalleCod="";
						}
						if(!codAnt.equals(codE))
						{
					%></table>
							</td>
							<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,50,3,2000,null,"width='100%'",null)%></td>
								</tr>
							<%	detalleCod="";
						}
				De++;
				}//else%>
<%}%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right"><cellbytelabel>Total</cellbytelabel>:
				<%//=fb.intBox("total2",""+eTotal+"",false,false,true,2)%>
				<%=fb.intBox("total2",tmpTot,false,false,true,2)%></td>
				<td><b><label id="clasificacion" style="color:green">&nbsp;</label></b></td>
				</tr>
<%=fb.hidden("size",""+lc)%>

			<tr class="TextRow02" >
				<td colspan="3" align="right">
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
			</tr>
			<%=fb.formEnd(true)%>
			<script type="text/javascript">sumaEscala("<%=eTotal%>");</script>
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
	int size = 0;
	int tpuntos=0;
  String dolor ="",intervencion="";

	Escalas eco = new Escalas();
	eco.setAdmision(request.getParameter("noAdmision"));
	eco.setPacId(request.getParameter("pacId"));
	eco.setFecha(request.getParameter("fecha"));
	eco.setHora(request.getParameter("hora"));
	eco.setTipo(request.getParameter("fg"));
	eco.setId(request.getParameter("id"));
	eco.setTotal(request.getParameter("total2"));
	eco.setLocalizacion(request.getParameter("localizacion"));
	eco.setUsuario((String) session.getAttribute("_userName"));
	if (request.getParameter("sizeD") != null) size = Integer.parseInt(request.getParameter("sizeD"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarD"+i) != null && request.getParameter("aplicarD"+i).equalsIgnoreCase("S"))
		{
			if(!dolor.trim().equals(""))
			dolor += "|"+request.getParameter("idD"+i);
			else dolor += request.getParameter("idD"+i);
		}
	}
	if (request.getParameter("sizeIM") != null) size = Integer.parseInt(request.getParameter("sizeIM"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarMe"+i) != null && request.getParameter("aplicarMe"+i).equalsIgnoreCase("S"))
		{
			if(!intervencion.trim().equals(""))
			intervencion += "|"+request.getParameter("idMe"+i);
			else intervencion += request.getParameter("idMe"+i);
		}
	}
	if (request.getParameter("sizeNF") != null) size = Integer.parseInt(request.getParameter("sizeNF"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarNf"+i) != null && request.getParameter("aplicarNf"+i).equalsIgnoreCase("S"))
		{
			if(!intervencion.trim().equals(""))
			intervencion +="|"+request.getParameter("idNf"+i);
			else intervencion +=request.getParameter("idNf"+i);
		}
	}



if(!fg.trim().equals("MO") && !fg.trim().equals("DO"))
eco.setIntervencion(""+intervencion);
else eco.setIntervencion(request.getParameter("intervencion"));

eco.setDolor(""+dolor);


if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

for (int i=1; i<=size; i++)
{
			if(request.getParameter("escala"+i) != null){
			DetalleEscala dre = new DetalleEscala();

			dre.setTipo(request.getParameter("fg"+i));//codigo
			dre.setCodEscala(request.getParameter("cod_escala"+i));//codigo

			/*if(request.getParameter("valIni").equals("1"))
			{
					dre.setDetalle(request.getParameter("codDetalleL"+i));//codDetalle
					dre.setValor(request.getParameter("valorL"+i));//
					tpuntos += Integer.parseInt(request.getParameter("valorL"+i));
			}
			else*/
			if(request.getParameter("escala"+i) != null)
			{
					dre.setDetalle(request.getParameter("codDetalle"+i));//codDetalle
					dre.setValor(request.getParameter("valor"+i));//
					//tpuntos = Integer.parseInt(request.getParameter("total2"));
			}


			dre.setAplicar("S");//
			dre.setObservacion(request.getParameter("observacion"+i));	//obsservacion

			eco.addDetalleEscala(dre);
			}
}
					//eco.setTotal(""+tpuntos);
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());

					if(modeSec.trim().equals("add"))
					{
							ECMgr.add(eco);
							id=ECMgr.getPkColValue("id");
					}
					else
					{
							ECMgr.update(eco);
							id=request.getParameter("id");
					}
			ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ECMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%>';
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_escalas_dolor.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escalas_dolor.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
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
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>