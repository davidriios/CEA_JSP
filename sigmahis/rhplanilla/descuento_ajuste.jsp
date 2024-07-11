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
<jsp:useBean id="iDesc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDesc" scope="session" class="java.util.Vector"/>

<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
StringBuffer sql=new StringBuffer();
String key="";
String empId= request.getParameter("empId");
String mode=request.getParameter("mode");
String anio=request.getParameter("anio");
String codPlanilla=request.getParameter("codPlanilla");
String noPlanilla=request.getParameter("noPlanilla");
String secuencia=request.getParameter("secuencia");
String monto=request.getParameter("monto");
String secuenciaTrx=request.getParameter("secuenciaTrx");
String fg=request.getParameter("fg");
String empIdTrx = request.getParameter("empIdTrx");
String fp=request.getParameter("fp");


boolean viewMode = false;

ArrayList al= new ArrayList();
String change= request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int desclastLineNo =0;

if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;
if(mode ==null)mode="add";
if(mode.trim().equals("view"))viewMode=true;
if(monto ==null)monto="0";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(change==null)
{
		iDesc.clear();
		vDesc.clear();
sql.append("select t.anio,t.cod_planilla, t.num_planilla, t.secuencia, t.cod_grupo, t.cod_acreedor, t.provincia, t.sigla, t.tomo, t.asiento, t.monto, t.usuario_creacion,t.usuario_mod, t.comision, t.num_descuento, t.cod_acreedor2, t.cod_compania, t.num_cheque, t.estado, t.autoriza_descto_cia, t.autoriza_descto_anio, t.autoriza_descto_codigo, t.emp_id ,(select nombre from tbl_pla_grupo_descuento where cod_grupo =t.cod_grupo ) descGrupo,(select nombre from tbl_pla_acreedor where cod_acreedor =t.cod_acreedor and compania=t.cod_compania) descAcreedor ,to_char(t.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion from tbl_pla_descuento_ajuste t where emp_id = ");
sql.append(empId);
sql.append(" and t.anio =");
sql.append(anio);
sql.append(" and t.cod_planilla =");
sql.append(codPlanilla);
sql.append(" and t.num_planilla =");
sql.append(noPlanilla);
sql.append(" and t.secuencia =");
sql.append(secuencia);

		al=SQLMgr.getDataList(sql.toString());
		desclastLineNo=al.size();
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");

				iDesc.put(cdo2.getKey(),cdo2);
				vDesc.add(cdo2.getColValue("cod_acreedor")+"-"+cdo2.getColValue("cod_grupo"));
			}
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Descuento de Empleados - Agregar - "+document.title;
function grup(k){abrir_ventana1('../common/search_grupo_descuento.jsp?fp=descuento&index='+k);}
function acred(k){abrir_ventana1('../rhplanilla/lista_acredor.jsp?empId=<%=empId%>&index='+k+'&fp=descAjuste&mode=edit');}
function setPatientInfo(formName){document.forms[formName].provincia.value=document.empleado.provincia.value;document.forms[formName].sigla.value=document.empleado.sigla.value;	document.forms[formName].tomo.value=document.empleado.tomo.value;	document.forms[formName].asiento.value=document.empleado.asiento.value;	document.forms[formName].num_empleado.value=document.empleado.num_empleado.value;}
function doAction(){setPatientInfo('form1');}
function checkMonto(){var monto = parseFloat(document.form1.monto.value).toFixed(2);var total =0.00;	var size1 = parseInt(document.getElementById("keySize").value);for (i=0;i<size1;i++){total +=  parseFloat(eval('document.form1.monto'+i).value);}total = total.toFixed(2);if(total>0 && total != monto){alert('El monto registrado para descuentos de acreedores no Coincide.. Favor verifique!!' ); return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DESCUENTO DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">

<tr class="TextRowWhite">
	<td width="100%">
	<jsp:include page="../common/empleado.jsp" flush="true">
	<jsp:param name="empId" value="<%=empId%>"></jsp:param>
	<jsp:param name="fp" value="descuento"></jsp:param>
	<jsp:param name="mode" value="view"></jsp:param>
</jsp:include>
	</td>
</tr>

	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("desclastLineNo",""+desclastLineNo)%>
	<%=fb.hidden("keySize",""+iDesc.size())%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("codPlanilla",codPlanilla)%>
	<%=fb.hidden("noPlanilla",noPlanilla)%>
	<%=fb.hidden("secuencia",secuencia)%>
	<%=fb.hidden("monto",monto)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("provincia","")%>
	<%=fb.hidden("sigla","")%>
	<%=fb.hidden("tomo","")%>
	<%=fb.hidden("asiento","")%>
	<%=fb.hidden("num_empleado","")%>
	<%=fb.hidden("secuenciaTrx",""+secuenciaTrx)%>
	<%=fb.hidden("fg",""+fg)%>
	<%=fb.hidden("fp",""+fp)%>
	<%=fb.hidden("empIdTrx",""+empIdTrx)%>
	<%fb.appendJsValidation("if(!checkMonto())error++;");%>

	<tr class="TextHeader">
		<td colspan="4">&nbsp;<cellbytelabel>Generales de Descuento</cellbytelabel></td>
	</tr>

	<tr>
		<td colspan="4">
		<table width="100%">
			<tr class="TextHeader" align="center">
				<td width="10%"><cellbytelabel>N&uacute;m</cellbytelabel>.</td>
				<td align="center"><cellbytelabel>Grupo de Descuento</cellbytelabel></td>
				<td align="center"><cellbytelabel>Acreedor</cellbytelabel></td>
				<td width="15%"><cellbytelabel>Monto</cellbytelabel></td>
				<td width="4%"><%=fb.submit("btnagregar","+",false,viewMode)%></td>
			</tr>
	<%
	String id="0";
	if(iDesc.size()>0)
	al=CmnMgr.reverseRecords(iDesc);
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos =(CommonDataObject) iDesc.get(key);
	    String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
		String color="";
	 	String fecharec="fecharec"+i;
		if(i%2 == 0) color ="TextRow02";
		else color="TextRow01";
	%>
	<%=fb.hidden("autoriza_descto_cia"+i,cdos.getColValue("autoriza_descto_cia"))%>
	<%=fb.hidden("autoriza_descto_anio"+i,cdos.getColValue("autoriza_descto_anio"))%>
	<%=fb.hidden("autoriza_descto_codigo"+i,cdos.getColValue("autoriza_descto_codigo"))%>
	<%=fb.hidden("comision"+i,cdos.getColValue("comision"))%>
	<%=fb.hidden("cod_acreedor2"+i,cdos.getColValue("cod_acreedor2"))%>
	<%=fb.hidden("num_cheque"+i,cdos.getColValue("num_cheque"))%>
	<%=fb.hidden("estado"+i,cdos.getColValue("estado"))%>
	<%=fb.hidden("fecha_creacion"+i,cdos.getColValue("fecha_creacion"))%>
	<%=fb.hidden("usuario_creacion"+i,cdos.getColValue("usuario_creacion"))%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<tr class="TextRow01" align="center" <%=style%>>
		<td align="center"><%=fb.intBox("num_descuento"+i,cdos.getColValue("num_descuento"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,true,5,3,"Text10",null,null)%></td>
		<td><%=fb.intBox("cod_grupo"+i,cdos.getColValue("cod_grupo"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,true,1,2,"Text10",null,null)%>
			<%=fb.textBox("descGrupo"+i,cdos.getColValue("descGrupo"),false,false,true,25,200,"Text10",null,null)%>
			<%//=fb.button("btngrupo"+i,"...",true,viewMode,"Text10", null,"onClick=\"javascript:grup("+i+");\"" )%>	</td>
		<td><%=fb.intBox("cod_acreedor"+i,cdos.getColValue("cod_acreedor"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,true,1,3,"Text10",null,null)%>
			<%=fb.textBox("descAcreedor"+i,cdos.getColValue("descAcreedor"),false,false,true,25,200,"Text10",null,null)%>
			<%=fb.button("btnacredor"+i,"...",true,viewMode,"Text10", null,"onClick=\"javascript:acred("+i+");\"" )%></td>
		<td><%=fb.decBox("monto"+i,((monto!=null && !monto.trim().equals("")&& !monto.trim().equals("0"))?cdos.getColValue("monto"):"0"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,15.2)%></td>
		<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
		</tr>

	<%  }%>
	</table>
</td>
</tr>

	<tr class="TextRow02">
        <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
		<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto -->
		<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>  </td>
    </tr>
	<tr>
		<td colspan="4">&nbsp;</td>
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
else if(request.getMethod().equalsIgnoreCase("POST"))
{

String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";

iDesc.clear();
vDesc.clear();
for(int a=0; a<keySize; a++)
{

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_pla_descuento_ajuste");
  cdo1.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and anio="+anio+" and cod_planilla="+codPlanilla+" and num_planilla="+noPlanilla+" and secuencia="+secuencia+" and num_descuento="+request.getParameter("num_descuento"+a));


  cdo1.addColValue("emp_id",empId);
  cdo1.addColValue("provincia",request.getParameter("provincia"));
  cdo1.addColValue("sigla",request.getParameter("sigla"));
  cdo1.addColValue("tomo",request.getParameter("tomo"));
  cdo1.addColValue("asiento",request.getParameter("asiento"));
  cdo1.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
  cdo1.addColValue("cod_grupo",request.getParameter("cod_grupo"+a));
  cdo1.addColValue("descGrupo", request.getParameter("descGrupo"+a));
  cdo1.addColValue("cod_acreedor",request.getParameter("cod_acreedor"+a));
  cdo1.addColValue("descAcreedor",request.getParameter("descAcreedor"+a));
  cdo1.addColValue("estado",request.getParameter("estado"+a));
  cdo1.addColValue("monto",request.getParameter("monto"+a).replaceAll(",",""));
  cdo1.addColValue("fecha_mod",cDateTime);
  cdo1.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
  cdo1.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
  cdo1.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
  cdo1.addColValue("anio",request.getParameter("anio"));
  cdo1.addColValue("cod_planilla",request.getParameter("codPlanilla"));
  cdo1.addColValue("num_planilla",request.getParameter("noPlanilla"));
  cdo1.addColValue("secuencia",request.getParameter("secuencia"));
  cdo1.addColValue("comision",request.getParameter("comision"+a));
  cdo1.addColValue("num_descuento",request.getParameter("num_descuento"+a));
  cdo1.addColValue("cod_acreedor2",request.getParameter("cod_acreedor2"+a));
  cdo1.addColValue("num_cheque",request.getParameter("num_cheque"+a));
  cdo1.addColValue("autoriza_descto_cia",request.getParameter("autoriza_descto_cia"+a));
  cdo1.addColValue("autoriza_descto_anio",request.getParameter("autoriza_descto_anio"+a));
  cdo1.addColValue("autoriza_descto_codigo", request.getParameter("autoriza_descto_codigo"+a));
  cdo1.setKey(a);
  cdo1.setAction(request.getParameter("action"+a));

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdo1.getColValue("num_descuento")+"-"+cdo1.getColValue("secuencia");
		if (cdo1.getAction().equalsIgnoreCase("I")) cdo1.setAction("X");//if it is not in DB then remove it
		else cdo1.setAction("D");
	}

	if (!cdo1.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iDesc.put(cdo1.getKey(),cdo1);
			vDesc.add(cdo1.getColValue("cod_acreedor")+"-"+cdo1.getColValue("cod_grupo"));
			list.add(cdo1);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

 }//End For

	if(!itemRemoved.equals(""))
	{
	//iDesc.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&anio="+anio+"&mode="+mode+"&anio="+anio+"&codPlanilla="+codPlanilla+"&noPlanilla="+noPlanilla+"&secuencia="+secuencia+"&monto="+monto+"&secuenciaTrx="+secuenciaTrx+"&fg="+fg+"&empIdTrx="+empIdTrx+"&fp="+fp);
	return;
	}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo1 = new CommonDataObject();
cdo1.addColValue("cod_grupo","");
cdo1.addColValue("cod_acreedor","");
cdo1.addColValue("NUM_DESCUENTO","0");
cdo1.addColValue("fecha_creacion",cDateTime);
cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
cdo1.setAction("I");
cdo1.setKey(iDesc.size() + 1);

iDesc.put(cdo1.getKey(),cdo1);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&mode="+mode+"&anio="+anio+"&codPlanilla="+codPlanilla+"&noPlanilla="+noPlanilla+"&secuencia="+secuencia+"&monto="+monto+"&secuenciaTrx="+secuenciaTrx+"&fg="+fg+"&empIdTrx="+empIdTrx+"&fp="+fp);
 return;

}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_pla_descuento_ajuste");
cdo1.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and anio="+anio+" and cod_planilla="+codPlanilla+" and num_planilla="+noPlanilla+" and secuencia="+secuencia);
cdo1.setKey(iDesc.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%

	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/descuento_ajuste.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/descuento_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/reg_pagoajuste_config.jsp?emp_id=<%=empIdTrx%>&mode=<%=mode%>&anio=<%=anio%>&noPlanilla=<%=noPlanilla%>&codPlanilla=<%=codPlanilla%>&secuencia=<%=secuenciaTrx%>&fg=<%=fp%>';
<%
		}

	//}

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&anio=<%=anio%>&codPlanilla=<%=codPlanilla%>&noPlanilla=<%=noPlanilla%>&secuencia=<%=secuencia%>&monto=<%=monto%>&secuenciaTrx=<%=secuenciaTrx%>&fg=<%=fg%>&empId=<%=empId%>&empIdTrx=<%=empIdTrx%>&fp=<%=fp%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
