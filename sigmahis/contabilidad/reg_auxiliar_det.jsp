<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iReg" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>


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

String mode=request.getParameter("mode");
String anio=request.getParameter("anio");
String fg=request.getParameter("fg");
String fp=request.getParameter("fp");
String no=request.getParameter("no");
String renglon=request.getParameter("renglon");
String tipo=request.getParameter("tipo");
String idTrx =request.getParameter("idTrx");

boolean viewMode = false;
ArrayList alRefType = new ArrayList();
ArrayList al= new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String change= request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(mode ==null)mode="add";
if(mode.trim().equals("view"))viewMode=true;
String compania = (String) session.getAttribute("_companyId");
if(fg ==null)fg="";
if(fp ==null)fp="";
if(idTrx ==null)idTrx="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql.append("select replace(nvl(get_sec_comp_param(");
	sql.append(session.getAttribute("_companyId"));
	sql.append(",'TP_CLIENT_CXP'),'-'),' ','') as tpCxP from dual");
	CommonDataObject p = SQLMgr.getData(sql);
	if (p != null && p.getColValue("tpCxP").equals("-")) throw new Exception("El parámetro [TP_CLIENT_CXP] no está definido!");

 		sql = new StringBuffer();
		sql.append("select det.ano, det.consecutivo, det.compania, det.renglon,det.tipo, det.ano_cta anocta, det.cta1, det.cta2, det.cta3, det.cta4, det.cta5, det.cta6, det.tipo_mov tipomov, det.valor,det.comentario||decode(det.ref_id,'-',' ',' - '||(det.ref_id ||' - '||det.ref_desc ))as comentario, det.ref_type as refType, det.ref_id as refId, det.ref_desc as refDesc,'U' action,(select cg.descripcion from tbl_con_catalogo_gral cg  where cg.cta1=det.cta1 and cg.cta2 =det.cta2 and cg.cta3 =det.cta3 and cg.cta4 =det.cta4 and cg.cta5=det.cta5 and cg.cta6=det.cta6 and cg.compania=det.compania ) as descCuenta,det.cta1||'.'||det.cta2||'.'||det.cta3||'.'||det.cta4||'.'||det.cta5||'.'||det.cta6 as cuenta from tbl_con_detalle_comprob det where det.compania=");
		sql.append(session.getAttribute("_companyId"));
		sql.append(" and det.ano=");
		sql.append(anio);
		if(fg.trim().equals("")){		
		sql.append(" and det.consecutivo=");
		sql.append(no);		
		sql.append(" and det.renglon=");
		sql.append(renglon);
		sql.append(" and det.tipo=");
		sql.append(tipo);
		}else
		{   sql.append(" and exists (select null from tbl_con_registros_auxiliar  where id=");
			sql.append(idTrx);
			sql.append(" and compania=");
		    sql.append(session.getAttribute("_companyId"));
			sql.append(" and  ref_type =");
			if(fg.trim().equals("CSCXP"))sql.append(" 2 ");
			else if(fg.trim().equals("CSCXC"))sql.append(" 1 ");
			sql.append("  and trans_id=det.consecutivo and trans_anio=det.ano and trans_renglon=det.renglon and trans_tipo=det.tipo  )");
		
		 }
			
		cdo = SQLMgr.getData(sql);
			
		if(cdo.getColValue("refType").trim().equals("1"))
			alRefType = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+compania+" and (activo_inactivo='A' or afecta_aux='S') order by 2",CommonDataObject.class);
			else alRefType = sbb.getBeanList(ConMgr.getConnection()," select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+compania+" and afecta_aux='S' and codigo in ( select column_value  from table( select split((select get_sec_comp_param("+compania+",'TP_CLIENT_CXP') from dual),',') from dual  ))",CommonDataObject.class);
	if (alRefType.size() == 0) throw new Exception("El Tipo de Referencia no está definido. Por favor consulte con su Administrador!");

if(change==null)
{
		iReg.clear();
		
		
		sql=new StringBuffer();
sql.append("select id,compania, ref_type, subref_type, ref_id, monto, lado, comentario, usuario_creacion, usuario_modificacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, estado, documento, referencia, afecta_aux, to_char(fecha_doc,'dd/mm/yyyy')fecha_doc, trans_id, trans_anio, trans_renglon, trans_tipo,nombre,reg_sistema,ruc,dv from tbl_con_registros_auxiliar where compania=");
sql.append(session.getAttribute("_companyId"));

 if(fg.trim().equals("")){
 sql.append(" and trans_id =");
sql.append(no);
sql.append(" and trans_anio= ");
sql.append(anio);
sql.append(" and trans_renglon= ");
sql.append(renglon);
sql.append(" and trans_tipo=");
sql.append(tipo); 
}else
{ sql.append(" and id=");sql.append(idTrx);}


sql.append(" order by id desc ");

		al=SQLMgr.getDataList(sql.toString());
			for(int h=0;h<al.size();h++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(h);
				cdo2.setKey(h);
				cdo2.setAction("U");

				iReg.put(cdo2.getKey(),cdo2);
			}
}

%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Detalle Auxiliar - Agregar - "+document.title;
function getClient(k){
eval('document.form1.referencia'+k).value='';
var refType = document.form1.refType.value;
var referTo=getSelectedOptionTitle(eval('document.form1.subref_type'+k),eval('document.form1.subref_type'+k).value);
var ref_id = eval('document.form1.subref_type'+k).value;

if(refType =='1'){
//abrir_ventana('../common/search_cliente.jsp?fp=comprob&fg=<%=fg%>&mode=<%=mode%>&referTo='+referTo);
if(ref_id!=''){abrir_ventana('../pos/sel_otros_cliente.jsp?fp=comprob&fg=<%=fg%>&mode=<%=mode%>&Refer_To='+referTo+'&ref_id='+ref_id+'&idx='+k); }else{alert('Seleccione Tipo Cliente');}

}
else if(refType=='2'){abrir_ventana('../pos/sel_otros_cliente.jsp?fp=comprob&fg=<%=fg%>&mode=<%=mode%>&Refer_To='+referTo+'&ref_id='+ref_id+'&idx='+k);}
} 

function doAction(){calc(false);}
function checkMonto(){var monto = parseFloat(document.form1.valor.value).toFixed(2);var total =0.00;	var size1 = parseInt(document.getElementById("keySize").value);for (i=0;i<size1;i++){if(eval('document.form1.action'+i).value !='D' && eval('document.form1.estado'+i).value !='I')
		{total +=  parseFloat(eval('document.form1.monto'+i).value);}}total = total.toFixed(2);if(parseFloat(total)>parseFloat(monto)){alert('El monto registrado en el detalle no conicide con el total registrado.. Favor verifique!!' ); return false;}else return true;}
function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalDb=0.00,totalCr=0.00,total=0.00;
	var size=parseInt(document.form1.keySize.value,10);
	var typeMov=document.form1.lado.value;
	var totalDet=document.form1.valor.value;
	for(i=0;i<size;i++)
	{
		//var typeMov=eval('document.form1.tipoMov'+i).value;
		if(eval('document.form1.action'+i).value !='D' && eval('document.form1.estado'+i).value !='I')
		{
			if(eval('document.form1.monto'+i).value!='' && !isNaN(eval('document.form1.monto'+i).value))
			{
			var valor=parseFloat(eval('document.form1.monto'+i).value);
			total +=valor;
			}
		}
		//if(typeMov=='DB')totalDb+=valor;
		//else totalCr+=valor;
	}

	//document.form1.sumDebito.value=(totalDb).toFixed(2);
	//document.form1.sumCredito.value=(totalCr).toFixed(2);
	//document.form1.totalDb.value=(totalDb).toFixed(2);
	//document.form1.totalCr.value=(totalCr).toFixed(2);
	
	document.form1.total.value=(total).toFixed(2);
	//alert('total =='+total+'   totalDet ==='+totalDet);
	if(total>totalDet)
	{
		if(showAlert)alert('El detalle del Comprobante no coincide con el encabezado');
		return false;
	}
	
	/*totalDb=(totalDb).toFixed(2);
	totalCr=(totalCr).toFixed(2);
	if(totalDb!=totalCr)
	{
		if(showAlert)alert('El Comprobante no está Balanceado');
		return false;
	}
	else if(totalDb==totalCr&&totalDb==0.00)
	{
		if(showAlert)alert('El Balance no puede ser igual a Cero (0)');
		return false;
	}*/
	return true;
}
function checkRef(k)
{
	var refType = document.form1.refType.value;
var referTo=getSelectedOptionTitle(eval('document.form1.subref_type'+k),eval('document.form1.subref_type'+k).value);
var ref_id = eval('document.form1.subref_type'+k).value;
var factura = eval('document.form1.referencia'+k).value;
var idCliente = eval('document.form1.ref_id'+k).value;

	if(refType =='1')
	{
		if(ref_id!='')
		{
			var  existe = getDBData('<%=request.getContextPath()%>','count(*) ','tbl_fac_factura','compania =<%=(String) session.getAttribute("_companyId")%> and estatus <> \'A\' and codigo=\''+factura+'\' and cod_otro_cliente=\''+idCliente+'\' and cliente_otros ='+ref_id,''); 
			
			if(existe==0)
			{
				if(confirm('El documento registrado no existe en sistema. Desea continuar con esta transaccion????'))
				{
					eval('document.form1.regSistema'+k).value="N";
				}
				else{eval('document.form1.referencia'+k).value="";}
			}else{eval('document.form1.regSistema'+k).value="S";}
			
		}
		else
		{
			alert('Seleccione Tipo Cliente');
		}
		
	}
	else if(refType=='2')
	{
		var tpCxP='<%=p.getColValue("tpCxP")%>';
		var vTP=tpCxP.split(",");
console.log('tpCxP='+tpCxP+' vTP='+vTP+' ref_id='+ref_id+' includes='+vTP.includes(ref_id));
		if(vTP.includes(ref_id))
		{
			var	 existe = getDBData('<%=request.getContextPath()%>','count(*) contador','tbl_inv_recepcion_material','compania =<%=(String) session.getAttribute("_companyId")%> and numero_factura=\''+factura+'\' and estado = \'R\' and cod_proveedor='+idCliente,'');
			
			if(existe==0)
			{
				if(confirm('El documento registrado no existe en sistema. Desea continuar con esta transaccion????'))
				{
					eval('document.form1.regSistema'+k).value="N";
				}
				else{eval('document.form1.referencia'+k).value="";eval('document.form1.regSistema'+k).value="N";}
			}else{eval('document.form1.regSistema'+k).value="S";}

		}else
		{
			if(ref_id!='')
		{
			var  existe = getDBData('<%=request.getContextPath()%>','count(*) ','tbl_fac_factura','compania =<%=(String) session.getAttribute("_companyId")%> and estatus <> \'A\' and codigo=\''+factura+'\'',''); 
			
			if(existe==0)
			{
				if(confirm('El documento registrado no existe en sistema. Desea continuar con esta transaccion????'))
				{
					eval('document.form1.regSistema'+k).value="N";
				}
				else{eval('document.form1.referencia'+k).value="";}
			}else{eval('document.form1.regSistema'+k).value="S";}
			
		}
		else
		{
			alert('Seleccione Tipo Cliente');
		}
		}
	}
}
function clearRef(k)
{
eval('document.form1.ref_id'+k).value="";
eval('document.form1.nombre'+k).value="";
eval('document.form1.referencia'+k).value="";
}
function printDet(det){abrir_ventana1('../contabilidad/print_reg_auxiliar_det.jsp?fp=asiento&fg=<%=fg%>&renglon=<%=cdo.getColValue("renglon")%>&no=<%=cdo.getColValue("consecutivo")%>&anio=<%=cdo.getColValue("ano")%>&tipo=<%=cdo.getColValue("tipo")%>&idTrx='+det);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DETALLE AUXILIAR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	
<tr class="TextRowWhite">
	<td width="100%">
	</td>
</tr>

	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("no",no)%>
	<%=fb.hidden("keySize",""+iReg.size())%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("renglon",renglon)%>
	<%=fb.hidden("tipo",tipo)%>
	<%=fb.hidden("baction","")%> 
	<%=fb.hidden("mode",mode)%> 
	<%=fb.hidden("provincia","")%>
	<%=fb.hidden("sigla","")%>
	<%=fb.hidden("tomo","")%>
	<%=fb.hidden("asiento","")%>
	<%=fb.hidden("num_empleado","")%>
	<%=fb.hidden("secuenciaTrx","")%>
	<%=fb.hidden("fg",""+fg)%>
	<%=fb.hidden("fp",""+fp)%>
	<%=fb.hidden("empIdTrx","")%>
	<%fb.appendJsValidation("if(!checkMonto())error++;");%>

	<tr class="TextHeader">
		<td colspan="5">&nbsp;Generales</td>
	</tr>
	<tr class="TextRow01">
	 <td width="20%">Año Comprobante:<%=fb.textBox("anio",cdo.getColValue("ano"),false,false,true,20,"Text10",null,null)%></td>
	 <td width="20%">No. Comprobante:<%=fb.decBox("consec",cdo.getColValue("consecutivo"),false,false,true,8,"Text10",null,"")%></td>
	 <td width="15%">&nbsp;</td>
	 <td width="30%">&nbsp;</td>
	 <td width="15%">&nbsp;</td>
	
	</tr>
	<tr class="TextRow01" align="center">
	<td colspan="2">Cuenta:<%=fb.textBox("cuenta",cdo.getColValue("cuenta"),false,false,true,20,"Text10",null,null)%>
		<%=fb.textBox("descCuenta",cdo.getColValue("descCuenta"),false,false,true,40,"Text10",null,null)%> &nbsp;&nbsp;Lado:<%=fb.select("lado","DB=DEBITO,CR=CREDITO",cdo.getColValue("tipoMov"),false,true,1,"Text10","","")%></td>
	<td>Monto:<%=fb.decBox("valor",cdo.getColValue("valor"),false,false,true,8,"Text10",null,"")%></td>
	<td>Comentario:<%=fb.textBox("comentario",cdo.getColValue("comentario"),false,false,true,50,"Text10",null,null)%></td>
	<td>Tipo: <%=fb.select("refType","0=DIARIO,1=CXC,2=CXP",cdo.getColValue("refType"),false,true,0,"Text10",null,"")%>
	<%=fb.button("btnRefDet","IMPRIMIR",true,((mode.trim().equals("add"))),null,null,"onClick=\"javascript:printDet('"+idTrx+"')\"")%>
	
	</td>
	
</tr>

	
	<tr>
		<td colspan="5">
		<table width="100%">
		
			<tr class="TextHeader" align="center">
				<td align="center" width="15%" >Tipo Cliente</td>
				<td align="center" width="20%">Cliente</td>
				<!--<td width="7%">Lado</td>-->
				<td width="6%">Monto</td>
				<td width="30%">Comentario</td>
				<td width="11%">Fecha Doc</td>
				<td width="09%">Referencia</td>
				<td width="07%">Estado</td>
				<td width="02%"><%=fb.submit("btnagregar","+",false,viewMode)%></td>
			</tr>
	<%
	String id="0"; 
					
	if(iReg.size()>0)
	al=CmnMgr.reverseRecords(iReg);
	
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos =(CommonDataObject) iReg.get(key);
	    String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
		String color="";								
	 	String fecharec="fecharec"+i;
		if(i%2 == 0) color ="TextRow02";
		else color="TextRow01";
	%>
	<%=fb.hidden("fecha_creacion"+i,cdos.getColValue("fecha_creacion"))%>
	<%=fb.hidden("usuario_creacion"+i,cdos.getColValue("usuario_creacion"))%>
	<%=fb.hidden("id"+i,cdos.getColValue("id"))%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<%=fb.hidden("no"+i,""+i)%>
	<%=fb.hidden("regSistema"+i,cdos.getColValue("reg_sistema"))%>
	<%=fb.hidden("ruc"+i,cdos.getColValue("ruc"))%>
	<%=fb.hidden("dv"+i,cdos.getColValue("dv"))%>
	<tr class="<%=color%>" align="center" <%=style%>>
		<td><%=fb.select("subref_type"+i,alRefType,cdos.getColValue("subref_type"),false,(viewMode),0,"Text10",null,"onChange=\"javascript:clearRef("+i+")\"",null,"S")%></td>
		<td><%=fb.textBox("ref_id"+i,cdos.getColValue("ref_id"),true,false,true,1,3,"Text10",null,null)%>
			<%=fb.textBox("nombre"+i,cdos.getColValue("nombre"),false,false,true,25,200,"Text10",null,null)%>
			<%=fb.button("btnRef"+i,"...",true,viewMode,"Text10", null,"onClick=\"javascript:getClient("+i+");\"" )%></td>
		<td><%//=fb.select("lado"+i,"DB=DEBITO,CR=CREDITO",cdos.getColValue("lado"),false,viewMode,1,"Text10","","onChange=\"javascript:calc(false)\"")%>
		 <%=fb.decBox("monto"+i,cdos.getColValue("monto"),((cdos.getAction().equalsIgnoreCase("D"))?false:true),false,viewMode,15,15.2,"Text10",null,"onChange=\"javascript:calc(true)\"")%></td>
		
		<td><%=fb.textarea("comentario"+i,cdos.getColValue("comentario"),false,false,viewMode,40,3,2000,"","width:100%","")%></td>
		<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="<%="fecha_doc"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=cdos.getColValue("fecha_doc")%>" />
				</jsp:include>
			</td>
		<td><%=fb.textBox("referencia"+i,cdos.getColValue("referencia"),true,false,false,15,30,"Text10",null,"onChange=\"javascript:checkRef("+i+")\"")%></td>
		<td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",cdos.getColValue("estado"),false,viewMode,1,"Text10","","")%></td>
		<td>
		<%if(!cdos.getAction().trim().equals("I")){%><a href="javascript:printDet('<%=cdos.getColValue("id")%>')"><img id="imgMayor<%=i%>" height="20" width="20" class="ImageBorder" src="../images/print.png"></a><%}%>
		<%=fb.submit("rem"+i,"X",true,(viewMode||!cdos.getColValue("id").trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
		</tr>
		
		
		
						
	<%  }%>
		<tr class="TextHeader" align="center">
				<td align="right"  colspan="2">Total </td>
				<td align="center"><%=fb.decBox("total","",false,false,true,15,15.2,"Text10",null,"")%></td>
				<td colspan="5">&nbsp;</td>
			</tr>
			
	</table>
</td>
</tr>
 	
	<tr class="TextRow02">
        <td align="right" colspan="5"> Opciones de Guardar: 
		<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
		<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto 
		<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar 
		<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>  </td>
    </tr>
	<tr>
		<td colspan="5">&nbsp;</td>
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

iReg.clear();
 
 for(int a=0; a<keySize; a++)
{ 

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_con_registros_auxiliar");  
  cdo1.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and id="+request.getParameter("id"+a));

  cdo1.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo1.addColValue("estado",request.getParameter("estado"+a));
  cdo1.addColValue("ref_type",request.getParameter("refType"));
  cdo1.addColValue("subref_type",request.getParameter("subref_type"+a));
  cdo1.addColValue("ref_id",request.getParameter("ref_id"+a));
  cdo1.addColValue("nombre",request.getParameter("nombre"+a));
  cdo1.addColValue("monto",request.getParameter("monto"+a));
  cdo1.addColValue("lado",request.getParameter("lado"));
  cdo1.addColValue("comentario",request.getParameter("comentario"+a));
  cdo1.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a)); 
  cdo1.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
  cdo1.addColValue("fecha_modificacion",cDateTime);
  cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo1.addColValue("documento",request.getParameter("documento"+a));
  cdo1.addColValue("referencia",request.getParameter("referencia"+a));
  cdo1.addColValue("fecha_doc",request.getParameter("fecha_doc"+a));
  cdo1.addColValue("afecta_aux",request.getParameter("afecta_aux"+a)); 
  cdo1.addColValue("reg_sistema",request.getParameter("regSistema"+a)); 
  cdo1.addColValue("ruc",request.getParameter("ruc"+a)); 
  cdo1.addColValue("dv",request.getParameter("dv"+a)); 

  cdo1.addColValue("trans_id",no);  
  cdo1.addColValue("trans_anio",anio); 
  cdo1.addColValue("trans_renglon",renglon);  
  cdo1.addColValue("trans_tipo",tipo);
  
  cdo1.setKey(a);
  cdo1.setAction(request.getParameter("action"+a));
		
  if (cdo1.getAction().equalsIgnoreCase("I")){			
  cdo1.setAutoIncCol("id");
  cdo1.setAutoIncWhereClause("compania="+compania);
  cdo1.addPkColValue("id","");}
  else cdo1.addColValue("id",request.getParameter("id"+a)); 
    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = request.getParameter("no"+a);
		if (cdo1.getAction().equalsIgnoreCase("I")) cdo1.setAction("X");//if it is not in DB then remove it
		else cdo1.setAction("D");
	}

	if (!cdo1.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iReg.put(cdo1.getKey(),cdo1);
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
	//iReg.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&no="+no+"&anio="+anio+"&mode="+mode+"&renglon="+renglon+"&tipo="+tipo+"&fg="+fg+"&fp="+fp);
	return;
	}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo1 = new CommonDataObject();
cdo1.addColValue("id","0");
cdo1.addColValue("fecha_doc",""+cDateTime.substring(0,10)); 
cdo1.addColValue("fecha_creacion",cDateTime);
cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
cdo1.addColValue("afecta_aux","N");
cdo1.addColValue("estado","A");

cdo1.setAction("I");
cdo1.setKey(iReg.size() + 1);

iReg.put(cdo1.getKey(),cdo1);

response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&no="+no+"&mode="+mode+"&anio="+anio+"&renglon="+renglon+"&tipo="+tipo+"&fg="+fg+"&fp="+fp);
 return;

}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_con_registros_auxiliar");  
cdo1.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and trans_id="+no+" and trans_anio="+anio+" and trans_renglon="+renglon+" and trans_tipo="+tipo);
   
cdo1.setKey(iReg.size() + 1);
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
	//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/reg_pagoajuste_config.jsp?no=<%=no%>&mode=<%=mode%>&anio=<%=anio%>&renglon=<%=renglon%>&tipo=<%=tipo%>&fg=<%=fp%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&anio=<%=anio%>&no=<%=no%>&renglon=<%=renglon%>&tipo=<%=tipo%>&fg=<%=fg%>&fp=<%=fp%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
