<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.io.File" %> 
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCarDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCarDet" scope="session" class="java.util.Vector"/>

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
CommonDataObject cdoEnc = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String key="";
String id= request.getParameter("id");
String renglon=request.getParameter("renglon"); 
String mode=request.getParameter("mode"); 
String fp=request.getParameter("fp"); 
String fg=request.getParameter("fg"); 
boolean viewMode = false;

ArrayList al= new ArrayList();
ArrayList alCds = new ArrayList();
String change= request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
 
if(mode ==null)mode="add";
if(mode.trim().equals("view"))viewMode=true; 
if(fp ==null)fp="";
if(fg ==null)fg="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		alCds = sbb.getBeanList(ConMgr.getConnection()," select codigo  as optValueColumn, descripcion as optLabelColumn from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))   /* and codigo in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+") */ ",CommonDataObject.class);
		 

		sql.append("select id, decode(esPac,'S',(select nombre_paciente from vw_adm_paciente where pac_id = c.pac_id),nombre) as nombre, estado, observacion, usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion,identificacion, to_char(fecha_nac,'dd/mm/yyyy') as fecha_nac , to_char(fecha,'dd/mm/yyyy')  as fecha,medico,procedimiento,other1,other2,other3,esPac,(select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)  from tbl_adm_medico where codigo=c.medico ) as nombreMedico,cod_proc,pac_id,nvl(get_sec_comp_param(c.compania,'FACT_APLICA_ITBMS_ANTES_DESC'),'N') aplicaItbms,reg_type,nvl(get_sec_comp_param(c.compania,'FACT_COT_CDS_PROC'),'N') setCds  from tbl_fac_cotizacion c where id=");
		sql.append(id);

		cdoEnc = SQLMgr.getData(sql.toString());

if(change==null)
{
		iCarDet.clear();
		vCarDet.clear();
			sql=new StringBuffer();	
sql.append("select  t.id, t.renglon, t.codigo,t.descripcion, t.cantidad, t.precio,t.precioitem, t.descuento, t.tipo_des,t.other1, t.other2,t.trabajo, t.cds, t.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo =t.tipo_servicio) as descTs ,t.keycargo from tbl_fac_cotizacion_item t where  id= ");
sql.append(id);
sql.append(" and t.renglon =");
sql.append(renglon); 

		al=SQLMgr.getDataList(sql.toString()); 
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");

				iCarDet.put(cdo2.getKey(),cdo2);
				vCarDet.add(cdo2.getColValue("trabajo")+"-"+cdo2.getColValue("keycargo"));
			}
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Detalle  - <%=(cdoEnc.getColValue("reg_type").trim().equals("COT"))?" Cotizacion ":" Paquete "%>"+document.title;
function cargos(){abrir_ventana1('../common/check_items_x_cds.jsp?fp=cotizacion&id=<%=id%>&renglon=<%=renglon%>&mode=<%=mode%>&fg=<%=fp%>&setCds=<%=cdoEnc.getColValue("setCds")%>');}
function doAction(){<% if (request.getParameter("type") != null && request.getParameter("type").equals("1")) { %>cargos();<% } %>}
function printCotizacionDet(){abrir_ventana('../facturacion/print_cotizacion_det.jsp?id=<%=id%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=(cdoEnc.getColValue("reg_type").trim().equals("COT"))?"DETALLE COTIZACION":"DETALLE PAQUETE"%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("renglon",""+renglon)%>
	<%=fb.hidden("keySize",""+iCarDet.size())%> 
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("fg",fg)%> 
	<%=fb.hidden("fp",fp)%> 
	
	<%//fb.appendJsValidation("if(!checkMonto())error++;");%>

	<tr class="TextHeader">
		<td colspan="4">&nbsp;<cellbytelabel><%=(cdoEnc.getColValue("reg_type").trim().equals("COT"))?"DETALLE COTIZACION":"DETALLE PAQUETE"%></cellbytelabel></td>
	</tr>
	<tr class="TextHeader01">
		<td colspan="3">[<%=id%>]<%=cdoEnc.getColValue("nombre")%></td>
		<td align="right"><%=fb.button("imprimir","IMPRIMIR",false,false,null,null,"onClick=\"javascript:printCotizacionDet()\"")%></td>
	</tr>

	<tr>
		<td colspan="4">
		<table width="100%">
			<tr class="TextHeader" align="center">
				<td width="23%"><cellbytelabel>Centro Servicio</cellbytelabel>.</td>
				<td width="22%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>
				<td width="30%"><cellbytelabel>Descripcion</cellbytelabel></td>
				<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
				<!--<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>-->
				<td width="5%"><%=fb.submit("btnagregar","+",false,viewMode)%></td>
			</tr>
	<%
	if(iCarDet.size()>0)
	al=CmnMgr.reverseRecords(iCarDet);
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos =(CommonDataObject) iCarDet.get(key);
	    String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:none\"":"";
		String color="";
	 	String fecharec="fecharec"+i;
		if(i%2 == 0) color ="TextRow02";
		else color="TextRow01";		
	%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<%=fb.hidden("tipo_servicio"+i,cdos.getColValue("tipo_servicio"))%>
	<%=fb.hidden("keyCargo"+i,cdos.getColValue("keyCargo"))%>
	<%=fb.hidden("trabajo"+i,cdos.getColValue("trabajo"))%>
	<%=fb.hidden("precioItem"+i,cdos.getColValue("precioItem"))%>
	<%=fb.hidden("codigo"+i,cdos.getColValue("codigo"))%>
	<%=fb.hidden("other1"+i,cdos.getColValue("other1"))%>
	<%=fb.hidden("precio"+i,cdos.getColValue("precio"))%>
	
	<tr class="TextRow01" align="center"<%=style%>>
		<td><%=fb.select("cds"+i,alCds,cdos.getColValue("cds"),false,false,((!cdos.getColValue("cds").trim().equals(""))?true:false),0,"Text10",null,null,"","S","")%></td>
		<td><%=fb.textBox("descTs"+i,cdos.getColValue("descTs"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%=fb.textBox("descripcion"+i,cdos.getColValue("descripcion"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%=fb.intBox("cantidad"+i,cdos.getColValue("cantidad"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,3)%></td>
		<!--<td><%//=fb.decBox("precio"+i,cdos.getColValue("precio"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,15.2)%></td>-->
		<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
	</tr>

	<%}%>
	</table>
</td>
</tr>

	<tr class="TextRow02">
        <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
		<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
iCarDet.clear();
vCarDet.clear();
for(int a=0; a<keySize; a++)
{

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_fac_cotizacion_item");
  cdo1.setWhereClause("id="+id+" and renglon="+renglon+" and codigo="+request.getParameter("codigo"+a));

  cdo1.addColValue("id",id);
  cdo1.addColValue("renglon",renglon);

  cdo1.addColValue("precio",request.getParameter("precio"+a));
  cdo1.addColValue("precioItem",request.getParameter("precioItem"+a));
  cdo1.addColValue("fecha_modificacion","sysdate");
  cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo1.addColValue("compania",(String) session.getAttribute("_companyId"));
  
  cdo1.addColValue("descTs",request.getParameter("descTs"+a));
  cdo1.addColValue("descripcion",request.getParameter("descripcion"+a));
  cdo1.addColValue("cantidad", request.getParameter("cantidad"+a));
  cdo1.addColValue("trabajo", request.getParameter("trabajo"+a));
  cdo1.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+a));
  cdo1.addColValue("keyCargo",request.getParameter("keyCargo"+a));
  cdo1.addColValue("other1",request.getParameter("other1"+a));
  cdo1.addColValue("cds", request.getParameter("cds"+a));
  cdo1.setKey(a);
  cdo1.setAction(request.getParameter("action"+a));
  
  if (baction.equalsIgnoreCase("Guardar") && cdo1.getAction().equalsIgnoreCase("I"))
  { 
	cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo1.addColValue("fecha_creacion","sysdate");
	cdo1.setAutoIncWhereClause("id = "+id+" and renglon = "+renglon);		 
	cdo1.setAutoIncCol("codigo");
  }
  else
  {
  	cdo1.addColValue("codigo",request.getParameter("codigo"+a));
  }

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdo1.getColValue("trabajo")+"-"+cdo1.getColValue("keyCargo");
		if (cdo1.getAction().equalsIgnoreCase("I")) cdo1.setAction("X");//if it is not in DB then remove it
		else cdo1.setAction("D");
	}

	if (!cdo1.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iCarDet.put(cdo1.getKey(),cdo1);
			vCarDet.add(cdo1.getColValue("trabajo")+"-"+cdo1.getColValue("keyCargo"));
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
	//iCarDet.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&renglon="+renglon+"&mode="+mode+"&fg="+fg+"&fp="+fp);
	return;
	}

if(request.getParameter("btnagregar")!=null)
{
  
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&id="+id+"&mode="+mode+"&renglon="+renglon+"&fg="+fg+"&fp="+fp);
 return;

}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_fac_cotizacion_item");
cdo1.setWhereClause(" id="+id+" and renglon="+renglon);
cdo1.setKey(iCarDet.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);

if (SQLMgr.getErrCode().equals("1")) {

CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_fac_cotizacion");
cdo1.addColValue("total_costo","(select round(sum(round((nvl(cantidad,0)*nvl(costo,0)),6) ),2) from  tbl_fac_cotizacion_item where id="+id+")");
cdo1.addColValue("total","(select round(sum(round((nvl(cantidad,0)*nvl(precio,0)),6) ),2) from  tbl_fac_cotizacion_item where id="+id+")");
cdo1.setWhereClause(" id="+id);

SQLMgr.update(cdo1);
}

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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/reg_cotizacion.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/reg_cotizacion.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/facturacion/reg_cotizacion.jsp?id=<%=id%>&mode=<%=mode%>&renglon=<%=renglon%>&fg=<%=fg%>&fp=<%=fp%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&id=<%=id%>&renglon=<%=renglon%>&fg=<%=fg%>&fp=<%=fp%>';
}
</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
