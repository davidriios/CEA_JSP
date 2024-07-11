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
<jsp:useBean id="iCarAjDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCarAjDet" scope="session" class="java.util.Vector"/>

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
CommonDataObject cdoP = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String key="";

String mode=request.getParameter("mode"); 
String fp=request.getParameter("fp"); 
String noAdmision=request.getParameter("noAdmision"); 
String pacienteId=request.getParameter("pacienteId");
String factura=request.getParameter("factura"); 
String fg=request.getParameter("fg");  
String tr=request.getParameter("tr"); 
String nt=request.getParameter("nt"); 
String cds=request.getParameter("cds"); 
String ts=request.getParameter("ts"); 
String codigo= request.getParameter("codigo");
String codDet=request.getParameter("codDet");
String wh=request.getParameter("wh"); 

boolean viewMode = false;

ArrayList al= new ArrayList();
ArrayList alCds = new ArrayList();
String change= request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
 
if(mode ==null)mode="add";
//if(mode.trim().equals("view"))viewMode=true; 
if(fp ==null)fp="";
if(fg ==null)fg=""; 
if(wh ==null)wh="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (cds == null) throw new Exception("El codigo del Centro de servicio no es válido. Por favor intente nuevamente!");
		alCds = sbb.getBeanList(ConMgr.getConnection()," select codigo  as optValueColumn, descripcion as optLabelColumn from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))   /* and codigo in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+") */ and codigo="+cds,CommonDataObject.class);
		 
    sql = sql.append("select param_value valida_dsp from tbl_sec_comp_param where compania in(-1,");
	sql.append(session.getAttribute("_companyId"));
	sql.append(") and param_name = 'CHECK_DISP' ");
	cdoP = SQLMgr.getData(sql);
	if(cdoP ==null){cdoP =new CommonDataObject();cdoP.addColValue("valida_dsp","S");}

if(change==null)
{
		iCarAjDet.clear();
		vCarAjDet.clear();
			sql=new StringBuffer();	
sql.append("select t.secuencia,t.nota_ajuste,t.codigo,t.compania,t.descripcion,t.cantidad,t.precio,t.precioitem,t.usuario_creacion,t.usuario_modificacion, t.fecha_creacion,t.fecha_modificacion,t.other1,t.other2,t.trabajo,t.cds,t.tipo_servicio,t.keycargo,t.estado,t.wh,t.disponible,t.msg,t.pac_id,t.admision,t.cargar,t.costo,t.factura,(select descripcion from tbl_cds_tipo_servicio where codigo =t.tipo_servicio) as descTs,t.cantidadCargo,t.recargo from tbl_con_adjustment_detail t where t.nota_ajuste= ");
sql.append(codigo);
sql.append(" and t.secuencia =");
sql.append(codDet); 
sql.append(" and t.compania =");
sql.append(session.getAttribute("_companyId")); 
 
		al=SQLMgr.getDataList(sql.toString()); 
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");

				iCarAjDet.put(cdo2.getKey(),cdo2);
				vCarAjDet.add(cdo2.getColValue("trabajo")+"-"+cdo2.getColValue("keycargo"));
			}
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Detalle  - Ajuste "+document.title;
function cargos(){var wh= document.form1.wh.value;

<%if(nt.trim().equals("C")){%>
abrir_ventana1('../common/check_items_x_cds.jsp?mode=<%=mode%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&factura=<%=factura%>&fg=<%=fg%>&tr=<%=tr%>&nt=<%=nt%>&cs=<%=cds%>&tipoServicio=<%=ts%>&codigo=<%=codigo%>&codDet=<%=codDet%>&setCds=S&valida_dsp=<%=cdoP.getColValue("valida_dsp")%>&wh='+wh);<%}else{%>
abrir_ventana1('../common/check_dev_item.jsp?mode=<%=mode%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&factura=<%=factura%>&fg=<%=fg%>&tr=<%=tr%>&nt=<%=nt%>&cs=<%=cds%>&tipoServicio=<%=ts%>&codigo=<%=codigo%>&codDet=<%=codDet%>&setCds=S&valida_dsp=<%=cdoP.getColValue("valida_dsp")%>&wh='+wh);<%}%>

}
function doAction(){<% if (request.getParameter("type") != null && request.getParameter("type").equals("1")) { %>cargos();<% } %>}
function printDet(){}
function chkValue(i){ 
	var art_flia 			= '';
	var art_clase 			= '';
	var cod_art 			= eval('document.form1.trabajo'+i).value;
	var cantidad 			= parseInt(eval('document.form1.cantidad'+i).value);
	var afecta_inv 			= eval('document.form1.afecta_inv'+i).value;
	var keyCargo 			= eval('document.form1.keyCargo'+i).value;
	var estado  		    = eval('document.form1.estado'+i).value;
	var cia					= '<%=session.getAttribute("_companyId")%>';
	var almacen				=  document.form1.wh.value;
	var cantidadCargo 		= parseInt(eval('document.form1.cantidadCargo'+i).value);
	var cds  		    = eval('document.form1.cds'+i).value;
	var ts  		    = eval('document.form1.tipo_servicio'+i).value;
	//alert('xxxxxxxxx valida_dsp== <%=cdoP.getColValue("valida_dsp")%>    WH = '+almacen+'   afecta_inv='+afecta_inv);
<%if(nt.trim().equals("C")){%>	
	<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>
	if(afecta_inv=='Y' && keyCargo=='ART'&& estado!='R')
	{
		var disponible = getInvDisponible('<%=request.getContextPath()%>',cia,almacen,art_flia,art_clase,cod_art);
		if(disponible <= 0)
		{
			CBMSG.warning('No hay disponibilidad para este artículo');
			eval('document.form1.cantidad'+i).value = 0;
		} 
		else if(cantidad > disponible)
		{
			CBMSG.warning('La cantidad introducida supera la disponible');			
			eval('document.form1.cantidad'+i).value = 0;
		}
	}
	<%}}else{%>
	
	
	var total = getDBData('<%=request.getContextPath()%>','(select nvl(sum(cantidad), 0) as cantidad from (select nvl(sum (decode(a.tipo_transaccion,\'D\',a.cantidad*-1,a.cantidad)), 0) as cantidad, case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then \'\'||a.otros_cargos when a.cds_producto is not null then \'\'||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then \'\'||a.inv_articulo when a.cod_uso is not null then \'\'||a.cod_uso when a.cod_paq_x_cds is not null then \'\'||a.cod_paq_x_cds else \' \' end as trabajo,case when a.procedimiento is not null then \'PROC\' when a.cds_producto is not null then \'PROD\' when a.habitacion is not null then \'HAB\' when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then  \'ART\' when a.cod_uso is not null then \'USO\' when a.cod_paq_x_cds is not null then \'PAQ\' else \' \' end as keyCargo from tbl_fac_detalle_transaccion a where  a.pac_id =<%=pacienteId%> and a.fac_secuencia =<%=noAdmision%> and a.compania ='+cia+' and a.centro_servicio <> 0 and centro_servicio = '+cds+' and tipo_cargo= \''+ts+'\' group by a.procedimiento,a.otros_cargos ,a.cds_producto ,a.habitacion,a.inv_almacen ,a.art_familia ,a.art_clase,a.inv_articulo,a.cod_uso,a.cod_paq_x_cds union all select nvl(sum (decode(a.tipo,\'D\',a.cantidad*-1,a.cantidad)), 0) as cantidad ,trabajo,keycargo  from tbl_con_adjustment_detail a where a.pac_id =<%=pacienteId%> and a.admision =<%=noAdmision%>  and a.compania ='+cia+' and a.nota_ajuste <> <%=codigo%> and a.secuencia <> <%=codDet%> and a.cds = '+cds+' and tipo_servicio=\''+ts+'\'  group by trabajo,keycargo ) where trabajo=\''+cod_art+'\' and keyCargo=\''+keyCargo+'\' ) as cantidad ',' dual ','','');
	

		

	
	  var action = eval('document.form1.action'+i).value;
	 if(action !='I') cantidadCargo = total; 
		if(cantidadCargo < cantidad)
		{
			CBMSG.warning('La cantidad a devolver es mayor que la cantidad registrada');
			eval('document.form1.cantidad'+i).value = 0;
		} 
	<%}%>
}
function cerrarAj()
{ 
var size = '<%=iCarAjDet.size()%>';
var wh				=  document.form1.wh.value;
if(parseInt(size) != 0){
 showPopWin('../process/fac_cierre_ajuste_inv.jsp?fp=FACT&codDet=<%=codDet%>&codigo=<%=codigo%>&wh='+wh+'&tipo=<%=nt%>',winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('No existe detalle registrado!');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DETALLE DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("keySize",""+iCarAjDet.size())%> 
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("fp",fp)%> 
	<%=fb.hidden("fg",fg)%>  
	<%=fb.hidden("noAdmision",noAdmision)%> 
	<%=fb.hidden("pacienteId",pacienteId)%> 
	<%=fb.hidden("factura",""+factura)%>
	<%=fb.hidden("tr",tr)%>  	
	<%=fb.hidden("nt",nt)%> 	
	<%=fb.hidden("cds",cds)%> 
	<%=fb.hidden("ts",ts)%>	
	<%=fb.hidden("codigo",codigo)%> 
	<%=fb.hidden("codDet",codDet)%>
	
	<%//fb.appendJsValidation("if(!checkMonto())error++;");%>
	<tr class="TextHeader01">
		<td colspan="4">&nbsp;<cellbytelabel>Almacen<%=fb.select(ConMgr.getConnection(),"SELECT distinct b.codigo_almacen as almacen, b.descripcion||' - '||b.codigo_almacen, b.codigo_almacen FROM tbl_inv_almacen b where b.compania="+(String) session.getAttribute("_companyId")+" ORDER  BY 1","wh",wh,false,false,0,"Text10",null,"onFocus=\"javascript:validarWh(this)\"")%></cellbytelabel></td>
	</tr>
	<tr class="TextHeader">
		<td colspan="4">&nbsp;<cellbytelabel>DETALLE AJUSTES</cellbytelabel></td>
	</tr>
	<!--<tr class="TextHeader01">
		<td colspan="3"></td>
		<td align="right"><%//=fb.button("imprimir","IMPRIMIR",false,false,null,null,"onClick=\"javascript:printCotizacionDet()\"")%></td>
	</tr>-->

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
	if(iCarAjDet.size()>0)
	al=CmnMgr.reverseRecords(iCarAjDet);
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos =(CommonDataObject) iCarAjDet.get(key);
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
	<%=fb.hidden("afecta_inv"+i,cdos.getColValue("afecta_inv"))%>
	<%=fb.hidden("estado"+i,cdos.getColValue("estado"))%>
	<%=fb.hidden("cantidadCargo"+i,cdos.getColValue("cantidadCargo"))%>
	<%=fb.hidden("costo_art"+i,cdos.getColValue("costo"))%>
	<%=fb.hidden("recargo"+i,cdos.getColValue("recargo"))%>
	<%=fb.hidden("inv_almacen"+i,cdos.getColValue("wh"))%>
	
	 
	 
	<tr class="TextRow01" align="center"<%=style%>>
		<td><%=fb.select("cds"+i,alCds,cdos.getColValue("cds"),false,false,((!cdos.getColValue("cds").trim().equals(""))?true:false),0,"Text10",null,null,"","S","")%></td>
		<td><%=fb.textBox("descTs"+i,cdos.getColValue("descTs"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%=fb.textBox("descripcion"+i,cdos.getColValue("descripcion"),false,false,true,50,200,"Text10",null,null)%></td>
		<td><%//=fb.intBox("cantidad"+i,cdos.getColValue("cantidad"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,3)%>
			<%=fb.intBox("cantidad"+i,cdos.getColValue("cantidad"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,((cdos.getColValue("estado").equalsIgnoreCase("R"))?true:false),10,3,"","","onChange=\"javascript:chkValue("+i+")\"","",false)%></td>
		<!--<td><%//=fb.decBox("precio"+i,cdos.getColValue("precio"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,15.2)%></td>-->
		<td><%=fb.submit("rem"+i,"X",true,((cdos.getColValue("estado").equalsIgnoreCase("R")||viewMode)?true:false),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
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
		<%=fb.button("actAjuste","Cerrar Ajuste",true,viewMode,null,null,"onClick=\"javascript:cerrarAj()\"","")%>
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
iCarAjDet.clear();
vCarAjDet.clear();
for(int a=0; a<keySize; a++)
{

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_con_adjustment_detail");
  cdo1.setWhereClause("nota_ajuste="+codigo+" and secuencia="+codDet+" and codigo="+request.getParameter("codigo"+a));

  cdo1.addColValue("nota_ajuste",codigo);
  cdo1.addColValue("secuencia",codDet);
  cdo1.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo1.addColValue("fecha_modificacion","sysdate");
  cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo1.addColValue("cds",cds);
  cdo1.addColValue("tipo_servicio",ts);
  cdo1.addColValue("pac_id",pacienteId);
  cdo1.addColValue("admision",noAdmision);
  cdo1.addColValue("factura",factura);
  cdo1.addColValue("tipo",nt);  
  cdo1.addColValue("wh",request.getParameter("wh"));
  if(nt.trim().equals("D")){
  cdo1.addColValue("wh",request.getParameter("inv_almacen"+a));
  
  cdo1.addColValue("cantidadCargo",request.getParameter("cantidadCargo"+a)); 
  cdo1.addColValue("costo_art",request.getParameter("costo_art"+a));
  cdo1.addColValue("costo",request.getParameter("costo_art"+a));
  cdo1.addColValue("recargo",request.getParameter("recargo"+a)); 
  
  }
  
  
  cdo1.addColValue("precio",request.getParameter("precio"+a));
  cdo1.addColValue("precioItem",request.getParameter("precioItem"+a));
  
  cdo1.addColValue("descTs",request.getParameter("descTs"+a));
  cdo1.addColValue("descripcion",request.getParameter("descripcion"+a));
  cdo1.addColValue("cantidad", request.getParameter("cantidad"+a));
  cdo1.addColValue("trabajo", request.getParameter("trabajo"+a));
  cdo1.addColValue("keyCargo",request.getParameter("keyCargo"+a));
  cdo1.addColValue("other1",request.getParameter("other1"+a));
  cdo1.addColValue("estado",request.getParameter("estado"+a));
  cdo1.setKey(a);
  cdo1.setAction(request.getParameter("action"+a));
  
  if (baction.equalsIgnoreCase("Guardar") && cdo1.getAction().equalsIgnoreCase("I"))
  { 
	cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo1.addColValue("fecha_creacion","sysdate");
	cdo1.setAutoIncWhereClause("nota_ajuste = "+codigo+" and secuencia = "+codDet);		 
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
			iCarAjDet.put(cdo1.getKey(),cdo1);
			vCarAjDet.add(cdo1.getColValue("trabajo")+"-"+cdo1.getColValue("keyCargo"));
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
	//iCarAjDet.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&change=1&codigo="+codigo+"&codDet="+codDet+"&mode="+mode+"&fg="+fg+"&fp="+fp+"&noAdmision="+noAdmision+"&pacienteId="+pacienteId+"&factura="+factura+"&tr="+tr+"&nt="+nt+"&cds="+cds+"&ts="+ts);
	return;  
	}

if(request.getParameter("btnagregar")!=null)
{  
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&codigo="+codigo+"&codDet="+codDet+"&mode="+mode+"&fg="+fg+"&fp="+fp+"&noAdmision="+noAdmision+"&pacienteId="+pacienteId+"&factura="+factura+"&tr="+tr+"&nt="+nt+"&cds="+cds+"&ts="+ts);
 return;
}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_con_adjustment_detail");
cdo1.setWhereClause(" nota_ajuste="+codigo+" and secuencia="+codDet);
cdo1.setKey(iCarAjDet.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);

/* if (SQLMgr.getErrCode().equals("1")){
 
CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	 
StringBuffer sbSql = new StringBuffer();
		sbSql.append("call sp_fac_detalle_aj_upd_inv (?,?,?,?,?)");
		param.setSql(sbSql.toString());
		
		param.addInNumberStmtParam(1,(String) session.getAttribute("_companyId"));
		param.addInNumberStmtParam(2,codigo);
		param.addInNumberStmtParam(3,codDet);		
		param.addInNumberStmtParam(4,wh);		
		param.addInStringStmtParam(5,(String) session.getAttribute("_userName"));

	 if (sbSql.length() > 0) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&codigo="+codigo+"&codDet="+codDet+"&fp="+fp+"&fg="+fg+"&wh="+wh);
		param = SQLMgr.executeCallable(param);
		ConMgr.clearAppCtx(null);
		//if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());

	}
}*/

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
	//window.opener.location = '<%=request.getContextPath()%>/facturacion/reg_cotizacion.jsp?codigo=<%=codigo%>&mode=<%=mode%>&codDet=<%=codDet%>&fg=<%=fg%>&fp=<%=fp%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&codigo=<%=codigo%>&codDet=<%=codDet%>&fg=<%=fg%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&factura=<%=factura%>&tr=<%=tr%>&nt=<%=nt%>&cds=<%=cds%>&ts=<%=ts%>&nt=<%=nt%>&nt=<%=nt%>';
	
}
</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
