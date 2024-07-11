<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="INCMgr" scope="page" class="issi.cxc.IncobrablesMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
fg = FI  --> FACTURAS INCOBRABLES EMPRESA 108
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
INCMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "",appendFilter2="";
String fgFilter = "";
String flag = "";
String fg = request.getParameter("fg");
String compId = (String) session.getAttribute("_companyId");
int iconHeight = 20;
int iconWidth = 20;
StringBuffer sbSql = new StringBuffer();
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String lista = request.getParameter("lista");
String anio = request.getParameter("anio");
String fecha = request.getParameter("fecha");
String tipo_ajuste = request.getParameter("tipo_ajuste");
String mode = request.getParameter("mode");
if(anio==null) anio = cDateTime.substring(6,10);
if(lista==null) lista = "";
if(fecha==null) fecha = "";
if(tipo_ajuste==null) tipo_ajuste = "";
if(mode==null) mode = "";


if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String codigo    = "";  // variable para mantener el valor de los campos filtrados en la consulta
	String secuencia = "";
	String nombre    = "";
	String factura   = "",fDate="",tDate="",fDateIng ="",tDateIng ="",facturaDesde="",facturaHasta="",montoLimite="";
	String fechaNac  = "",aseguradora="",aseguradoraDesc=request.getParameter("aseguradoraDesc");

	if (!anio.trim().equals("") && !lista.trim().equals("")){
		//sbSql.append(", decode(c.centro,null,decode(c.empresa,null,c.medico,c.empresa),c.centro) as codigo_cs,decode ( c.centro , null,decode(c.empresa,null,(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_de_casada from tbl_adm_medico where codigo = c.medico ),(select nombre from tbl_adm_empresa where codigo = c.empresa)),(select descripcion from tbl_cds_centro_servicio where codigo =c.centro)) descripcion_cs");

		sbSql.append("select cm.pac_id, to_char(cm.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, cm.codigo_paciente, cm.secuencia, to_char(cm.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, cm.factura, cm.lista, cm.rebajar, cm.categoria, cm.estado, cm.empresa as empresaenc, cm.cobrador, cm.anio, cm.compania");
		sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = cm.pac_id) as nombre_paciente");
		sbSql.append(", (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = cm.pac_id) as f_nac");
		sbSql.append(", (select to_char(fecha,'dd/mm/yyyy') from tbl_fac_factura where compania = cm.compania and codigo = cm.factura) as fecha");
		sbSql.append(", (select grang_total from tbl_fac_factura where compania = cm.compania and codigo = cm.factura) as grang_total");
		sbSql.append(", (select descripcion from tbl_adm_categoria_admision where codigo = cm.categoria) desccategoria");
		sbSql.append(", nvl((select to_char(max (ctp.fecha),'dd/mm/yyyy') ultimo_pago from tbl_cja_transaccion_pago ctp, tbl_cja_distribuir_pago cdp where cdp.fac_codigo = cm.factura and cdp.compania = cm.compania and (cdp.codigo_transaccion = ctp.codigo and cdp.tran_anio = ctp.anio) and ctp.rec_status = 'A'),' ') as ultimo_pago");
		sbSql.append(", (select nvl(sum(monto_rebajado),0) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and estado = 'A') as saldo");
		sbSql.append(", (select nvl(sum(nvl(a_amount,monto_rebajado)),0) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and estado = 'A') as ajustar");
		sbSql.append(", (select nvl(sum(cargos),0) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and estado = 'A') as monto");
		sbSql.append(", (select nvl(sum(pagos),0) from tbl_cxc_det_cuentasm where compania = cm.compania and anio = cm.anio and lista = cm.lista and factura = cm.factura and estado = 'A') as pagos");
		sbSql.append(" from tbl_cxc_cuentasm cm");
		sbSql.append(" where cm.compania = ");
		sbSql.append(compId);
		sbSql.append(" and cm.lista = ");
		sbSql.append(lista);
		sbSql.append(" and cm.anio = ");
		sbSql.append(anio);
		sbSql.append(" and cm.status = 'C'");
		if (!mode.equals("view")) sbSql.append(" and not exists (select referencia from tbl_fac_nota_ajuste where referencia = cm.anio||cm.lista and ajuste_lote = 'S')");
		sbSql.append(" order by 15, cm.factura");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count( distinct factura) count from ("+sbSql.toString()+")");
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var ignoreSelectAnyWhere = true;
function printFactura(factura){
	abrir_ventana1('../facturacion/print_factura.jsp?factura='+factura+'&compania=<%=compId%>');
}
function printEC(factId, pac_id){
	abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?factId='+factId+'&pacId='+pac_id);
}
function printList()
{
	 //abrir_ventana('../cxc/print_fact_incobrables.jsp?anio=<%=anio%>&lista=<%=lista%>');
	 var fecha = document.search01.fecha.value;
	 var lista = document.search01.lista.value;
	 var msg ='';

	 if(fecha =='' )msg +=' Fecha';
	 if(lista =='' )msg +=' No. Lista';

		if(msg !=''){alert('Seleccione: '+msg);  }
	 else    abrir_ventana('../cxc/print_ajuste_fact_incobrables.jsp?referencia=<%=anio%>'+lista+'&anio=<%=anio%>&lista='+lista+'&fecha='+fecha);
}
function printListIncob()
{
	 var anio = document.search01.anio.value;
	 var lista = document.search01.lista.value;
	 var msg ='';
	 if(anio =='' )msg +=' AÑO';
	 if(lista =='' )msg +=' No. Lista';

		if(msg !=''){alert('Seleccione: '+msg);  }
	 else    abrir_ventana('../cxc/print_fact_incobrables.jsp?anio='+anio+'&lista='+lista);
}
function printListAjuste(){
	var lista = document.search01.lista.value;
	var anio = document.search01.anio.value;
	abrir_ventana('../facturacion/print_list_ajuste_automatico.jsp?fg=ajuste_automatico&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>');
}
function showLista(k,codFac)
{
	var lista1 =eval('document.form1.noLista1'+k).value;
	var lista2 =eval('document.form1.noLista2'+k).value;

	var lista ='';
	if(lista1 !='' )lista=lista1;
	else lista = lista2;
	alert('Esta Factura Ya fue Rebajada en la Lista  '+lista);
	eval('document.form1.rebajar'+codFac).checked=false;
	calcTotal();
}

function calcTotal()
{
	var fac = '';
	var total =0,tClinica=0,tTerceros=0,tMedicos=0,tEmpresas=0;



	for(i=0;i<<%=al.size()%>;i++)
	{
		var codFac = eval('document.form1.codigo'+i).value;
		var ajustar = 0;
		//if(fac != eval('document.form1.codigo'+i).value )
		//{
			if(eval('document.form1.rebajar'+codFac).checked)
			{
				ajustar = parseFloat(eval('document.form1.ajustar'+i).value);
				total += ajustar;

			}//end checked

	}

	document.form1.totalIncob.value=(total).toFixed(2);
}

function verificaFactura(i,codFac)
{
	calcTotal();
}

function calcTot()
{
	var totalIncob = parseFloat(document.form1.totalIncob.value);
	var x=0;
	for(i=0;i<<%=al.size()%>;i++)
	{
		var codFac = eval('document.form1.codigo'+i).value;
		if(eval('document.form1.rebajar'+codFac).checked)
		{
			x++;
			break;
		}
	}

	if(x == 0){
	alert('No Existen Facturas Seleccionadas');
	return false;}
	else { return true;}
}

function anulaFactList(factura)
{
	 showPopWin('../process/cxc_anul_fac_aju_inc.jsp?mode=ina&fp=app_lista_inc&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&fg=<%=fg%>&factura='+factura,winWidth*.45,_contentHeight*.25,null,null,'');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CXC - CUENTAS INCOBRABLES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right"></td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("tipo_ajuste",tipo_ajuste)%>


			<td width="25%">
				Año
				<%=fb.intBox("anio",anio,false,false,false,10)%>
			</td>
			<td width="25%">
				No. Lista
				<%=fb.intBox("lista",lista,false,false,false,10)%><%=fb.submit("go","Ir")%>
			</td>
			<td width="50%">
				Parámetros de "Fecha" y "Hora", en que Cobros tiro el listado de Incobrables. <br>

				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>

	<%=fb.formEnd()%>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right"><authtype type='52'><a href="javascript:printListIncob()" class="Link00">[ Imprimir Reporte CXC ]</a></authtype>  <authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir ]</a></authtype><authtype type='53'><a href="javascript:printListAjuste()" class="Link00">[ Reporte Distribuido ]</a></authtype><!----></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
		<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
		<%=fb.hidden("searchOn",searchOn)%>
		<%=fb.hidden("searchVal",searchVal)%>
		<%=fb.hidden("searchValFromDate",searchValFromDate)%>
		<%=fb.hidden("searchValToDate",searchValToDate)%>
		<%=fb.hidden("searchType",searchType)%>
		<%=fb.hidden("searchDisp",searchDisp)%>
		<%=fb.hidden("searchQuery","sQ")%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("lista",lista)%>
		<%=fb.hidden("tipo_ajuste",tipo_ajuste)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
		<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
		<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
		<%=fb.hidden("searchOn",searchOn)%>
		<%=fb.hidden("searchVal",searchVal)%>
		<%=fb.hidden("searchValFromDate",searchValFromDate)%>
		<%=fb.hidden("searchValToDate",searchValToDate)%>
		<%=fb.hidden("searchType",searchType)%>
		<%=fb.hidden("searchDisp",searchDisp)%>
		<%=fb.hidden("searchQuery","sQ")%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("lista",lista)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
		<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("lista",lista)%><tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow01">
			<td align="right" colspan="17">Tipo de Ajuste:
				<%=fb.select(ConMgr.getConnection(),"select fta.codigo as codigo,fta.descripcion as descripcion,decode(fta.tipo_doc,'R','RECIBO','FACTURA')||' - '||(select description from tbl_fac_adjustment_group where id = fta.group_type and status ='A')descGrupo from tbl_fac_tipo_ajuste fta where fta.compania = "+(String) session.getAttribute("_companyId")+" and fta.group_type not in('A','H','D','E','O')  and fta.estatus ='A' and fta.tipo_doc ='F' order by fta.group_type,fta.descripcion ","tipo_ajuste",tipo_ajuste,true,false,false,0,"Text10","",null,null,"")%>
				<authtype type='52'><%=fb.submit("save","Guardar",true,(mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
			</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="18%">Nombre</td>
			<td width="5%">Fecha Nac.</td>
			<td width="4%">No. Pacte</td>
			<td width="4%">No. Adm.</td>
			<td width="8%">Categoria</td>
			<td width="6%">Fecha Ing.</td>
			<td width="7%">No. Factura</td>
			<td width="5%">Fecha</td>
			<td width="14%">Cobrador</td>
			<!--
			<td width="7%">Tipo Factura</td>
			<td width="6%">Estado</td>
			<td width="5%">Lista</td>-->
			<td width="6%">Monto</td>
			<td width="6%">Saldo</td>
			<td width="6%">Ajustar</td>
			<td width="5%">Ultimo pag.</td>
			<td width="3%">Incob.<br><%=fb.checkbox("_chkAll","S",false,false,"","","onClick=\"javascript:jqCheckAll('"+fb.getFormName()+"', 'rebajar', this, false);calcTotal();\"","")%></td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>


<%
int x=0;
String codFactura="";
double total=0,totalClinica =0,totalTerceros =0,totalMedicos =0,totalEmpresas =0,totalIncob=0,totalSel=0;
double tEmpresas =0,tClinica =0,tTerceros =0,tMedicos  =0, montoAjuste=0, _saldoFactura = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "";
	String color2 = "TextRow02";
	if (x % 2 == 0) color2 = "TextRow01";
	String displayDetail = "none";
	String displayEvent = "";//"onClick=javascript:showHide('CS"+cdo.getColValue("factura")+"')";
	String displayEvent2 = "onClick=javascript:verificaFactura("+i+",'"+cdo.getColValue("factura")+"')";
	//if(cdo.getColValue("rebajar") != null && cdo.getColValue("rebajar").trim().equals("S"))
	//displayEvent2 = "onClick=javascript:showLista("+i+",'"+cdo.getColValue("factura")+"')";
_saldoFactura += Double.parseDouble(cdo.getColValue("saldo"));
%>
<%=fb.hidden("codigo"+i,cdo.getColValue("factura"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("fecha_ingreso"+i,cdo.getColValue("fecha_ingreso"))%>
<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
<%=fb.hidden("codigo_cs"+i,cdo.getColValue("codigo_cs"))%>
<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
<%=fb.hidden("descripcion_cs"+i,cdo.getColValue("descripcion_cs"))%>
<%=fb.hidden("monto"+i,cdo.getColValue("cargos"))%>
<%=fb.hidden("pagos"+i,cdo.getColValue("pagos"))%>
<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>
<%=fb.hidden("ajustar"+i,cdo.getColValue("ajustar"))%>
<%=fb.hidden("centro"+i,cdo.getColValue("centro"))%>
<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>


 <%if (!codFactura.equals(cdo.getColValue("factura")))
	{
		color = "TextRow02";
		montoAjuste+=Double.parseDouble(cdo.getColValue("ajustar"));
		x = 0;
		if (i != 0)
		{
		total = Math.round(total * 100);
%>
						<tr class="TextHeader01">
							<td colspan="2"></td>
							<td colspan="3" align="right">S A L D O&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;F A C T U R A:
							<%=fb.decBox("total"+codFactura,""+(total/100),false,false,true,7,"Text10",null,null)%></td>
						</tr>


			</table>
		</td>
	</tr>
<%
		total =0;
		}
	}
%>
<%if (!codFactura.equals(cdo.getColValue("factura"))){%>

		<tr class="TextRow04" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left" <%=displayEvent%>><%=cdo.getColValue("nombre_paciente")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("pac_id")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("secuencia")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("descCategoria")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("fecha_ingreso")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("factura")%></td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("fecha")%></td>
			<td align="center"<%=displayEvent%>><%=cdo.getColValue("cobrador")%></td>
			<td align="right" <%=displayEvent%>><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%>&nbsp;</td>
			<td align="right" <%=displayEvent%>><%=CmnMgr.getFormattedDecimal(_saldoFactura)%>&nbsp;</td>
			<td align="right" <%=displayEvent%>><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustar"))%>&nbsp;</td>
			<td align="center" <%=displayEvent%>><%=cdo.getColValue("ultimo_pago")%></td>
			<td align="center"><%=fb.checkbox("rebajar"+cdo.getColValue("factura"),"S",(cdo.getColValue("rebajar") != null && cdo.getColValue("rebajar").equalsIgnoreCase("S")),false,"","",displayEvent2,"")%></td>

			<td align="center"><authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Factura')" onClick="javascript:printFactura('<%=cdo.getColValue("factura")%>')"></authtype>
			</td>
			<td align="center"><authtype type='51'><a href="javascript:printEC('<%=cdo.getColValue("factura")%>','<%=cdo.getColValue("pac_id")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">EC</a></authtype>
			</td>
			<td align="center"><authtype type='52'><%if(!mode.equals("view")){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/cancel.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Anular Factura')" onClick="javascript:anulaFactList('<%=cdo.getColValue("factura")%>')"><%}%></authtype>
			</td>
		</tr>


		<tr id="panelCS<%=cdo.getColValue("factura")%>" style="display:<%=displayDetail%>">
			<td colspan="17" class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="1">
				<%//if (!codFactura.equals(cdo.getColValue("cod_factura"))){%>
				<tr class="TextHeader01">
					<td width="15%">Codigo</td>
					<td width="40%" align="left">Descripci&oacute;n</td>
					<td width="15%" align="center">Cargos Netos</td>
					<td width="15%" align="center">Pagos</td>
					<td width="15%" align="right">Saldos</td>
				</tr>
				<%}%>

				<tr class="TextRow02">
					<td align="left"><%=cdo.getColValue("codigo_cs")%></td>
					<td align="left"><%=cdo.getColValue("descripcion_cs")%></td>
					<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos"))%></td>
					<td align="right"><%=cdo.getColValue("saldo")%></td>
				</tr>
<%
	total += Double.parseDouble(cdo.getColValue("saldo"));
	_saldoFactura = 0;
	totalIncob += Double.parseDouble(cdo.getColValue("saldo"));

	codFactura = cdo.getColValue("factura");


if (i == al.size() - 1)
	{

	total = Math.round((total) * 100);
%>
						<tr class="TextHeader01">
							<td colspan="2"></td>
							<td colspan="4" align="right">S A L D O&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;F A C T U R A:
							<%=fb.decBox("total"+codFactura,""+(total/100),false,false,true,7,"Text10",null,null)%></td>
						</tr>


					</table>
				</td>
			</tr>
<%
	}
}//for

		totalIncob = Math.round((totalIncob) * 100);
		montoAjuste = Math.round((montoAjuste) * 100);
%>
	<tr class="TextHeader02">
		<td colspan="3"></td>
		<td colspan="6" align="right">T O T A L  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L A&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;L I S T A:</td>
		<td colspan="3"align="right"> <%=fb.decBox("totalIncob",""+(montoAjuste/100),false,false,true,15,"Text10",null,null)%></td>
		<td colspan="5"align="right"></td>
	</tr>


	<tr  class="TextRow01">
					<td align="right" colspan="17"><authtype type='52'><%=fb.submit("save2","Guardar",true,(mode.equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype></td>
	</tr>
		</table>
	</td>
</tr>
<%fb.appendJsValidation("\n\tif (!calcTot())\n\t{\n\t\terror++;\n\t}\n");%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	<%=fb.formEnd(true)%>

</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("lista",lista)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("lista",lista)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post

 ArrayList al1= new ArrayList();
 int size =Integer.parseInt(request.getParameter("size"));

 String baction = request.getParameter("baction");

 for(int i=0;i<size;i++)
 {
	double saldoFactura =0;

			if(request.getParameter("total"+request.getParameter("codigo"+i)) != null && !request.getParameter("total"+request.getParameter("codigo"+i)).trim().equals(""))
			 saldoFactura = Double.parseDouble(request.getParameter("total"+request.getParameter("codigo"+i)));
			if(saldoFactura != 0)
			{


			CommonDataObject cdo = new CommonDataObject();
			//cdo.setTableName("tbl_fac_factura");
			//cdo.setWhereClause(" codigo ="+request.getParameter("codigo"+i)+" and compania="+(String) session.getAttribute("_companyId"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("anio",request.getParameter("anio"+i));

			cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
			cdo.addColValue("codigo_paciente",request.getParameter("codigo_paciente"+i));
			cdo.addColValue("admision",request.getParameter("secuencia"+i));
			cdo.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"+i));
			cdo.addColValue("categoria",request.getParameter("categoria"+i));
			//cdo.addColValue("estado",request.getParameter("estado"+i));
			//cdo.addColValue("monto_lista",request.getParameter("total"+request.getParameter("codigo"+i)));
			cdo.addColValue("pac_id",request.getParameter("pac_id"+i));
			cdo.addColValue("cobrador",request.getParameter("cobrador"+i));
			cdo.addColValue("pac_id",request.getParameter("pac_id"+i));
			cdo.addColValue("centro",request.getParameter("centro"+i));
			cdo.addColValue("medico",request.getParameter("medico"+i));
			cdo.addColValue("empresa",request.getParameter("empresa"+i));
			cdo.addColValue("tipo_ajuste",request.getParameter("tipo_ajuste"));


			cdo.addColValue("descripcion_cs",request.getParameter("descripcion_cs"+i));
			cdo.addColValue("codigo_cs",request.getParameter("codigo_cs"+i));

			//cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
			//cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("fecha_modifica",cDateTime);
			if (request.getParameter("rebajar"+request.getParameter("codigo"+i)) != null)
			cdo.addColValue("rebajar","S");
			else cdo.addColValue("rebajar","N");
			cdo.addColValue("monto",request.getParameter("monto"+i));
			cdo.addColValue("pagos",request.getParameter("pagos"+i));
			cdo.addColValue("saldo",request.getParameter("saldo"+i));
			cdo.addColValue("lista",request.getParameter("lista"));

			cdo.addColValue("delete","N");


			al1.add(cdo);

			}
 }

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"baction="+baction+" size="+al1.size());
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		INCMgr.updateLista(al1);
	}/**/

	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">

function closeWindow()
{
<%
if (INCMgr.getErrCode().equals("1"))
{
%>
	alert('<%=INCMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/list_rebajar_incobrables.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/list_rebajar_incobrables.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/cxc/list_rebajar_incobrables.jsp?mode=view&fg=<%=fg%>&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>';
<%
	}
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/ajuste_auto_list.jsp.jsp"))
	{
%>
	 window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/ajuste_auto_list.jsp.jsp")%>';

<%
	} else {
		%>
	window.opener.location = '<%=request.getContextPath()%>/cxc/ajuste_auto_list.jsp';
	<%}

} else throw new Exception(INCMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>