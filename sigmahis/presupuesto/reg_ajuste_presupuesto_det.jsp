<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.AjustePresupuesto"%>
<%@ page import="issi.presupuesto.AjusteDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="AjMgr" scope="page" class="issi.presupuesto.AjustePresupuestoMgr" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
AjMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String noAjuste = request.getParameter("noAjuste");

String change = request.getParameter("change");
int lastLineNo = 0;

boolean viewMode = false;
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	newHeight();
	<%
if (mode != null && !mode.trim().equals("view"))
{
%>
parent.form1BlockButtons(false);

<%}%>

<%
if (request.getParameter("type") != null)
{
%>
	var anio = parent.document.form1.anio.value;
	var tipoAjuste = parent.document.form1.codAjuste.value;
	abrir_ventana1('../contabilidad/sel_plan_ctas_comp.jsp?mode=<%=mode%>&fg=<%=fg%>&anio='+anio+'&tipoAjuste='+tipoAjuste+'&fp=PRES<%=fg%>&lastLineNo=<%=lastLineNo%>');
<%
}
%>
calc(false);

}

function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalSalida=0.00,totalEntrada=0.00;
	var size=parseInt(document.form1.size.value,10);
	var totalAjuste  = 0;
	if(parent.document.form1.monto.value !='' )totalAjuste=parseFloat(parent.document.form1.monto.value);
	var estado = parent.document.form1.estado.value ;
	var x=0;
	for(i=1;i<=size;i++)
	{
		var typeMov=eval('document.form1.movimiento'+i).value;
		var valor=parseFloat(eval('document.form1.montoOrigen'+i).value);
		var saldo =parseFloat(eval('document.form1.saldo'+i).value);
		if(typeMov=='S'){ if (valor> saldo){   x++;
         <%if (mode != null && !mode.trim().equals("view")){%>alert('El monto que sale es mayor que el saldo disponible, .. VERIFIQUE !');eval('document.form1.montoOrigen'+i).value=0;valor=0; <%}%>} }

		if(typeMov=='S')totalSalida+=valor;
		else totalEntrada+=valor;

	}

	parent.document.form1.totalEntradas.value=(totalEntrada).toFixed(2);
	parent.document.form1.totalSalidas.value=(totalSalida).toFixed(2);
	//parent.document.form1.totalDb.value=(totalDb).toFixed(2);
	//parent.document.form1.totalCr.value=(totalCr).toFixed(2);
	totalEntrada=(totalEntrada).toFixed(2);
	totalSalida=(totalSalida).toFixed(2);
	if(showAlert){
	//if(estado =='A')
	//{
			if(totalEntrada==totalSalida && totalSalida ==totalAjuste)
			{
			}
			else
			{
				alert('No estan balanceado el Total Entrada,Total salida Y el Monto Total del ajuste, ...VERIFIQUE!');
				x++;
			}
	 //}
	}
	if(x==0){return true;}
	else {return false;}
}

function doSubmit()
{
	var error=0;
	if(parent.form1Validation())
	{
		if(form1Validation())
		{
			document.form1.baction.value 			= parent.document.form1.baction.value;
			document.form1.anio.value 				= parent.document.form1.anio.value;
			document.form1.mes.value				= parent.document.form1.mes.value;
			document.form1.fechaDocumento.value		= parent.document.form1.fechaDocumento.value;
			document.form1.fechaSistema.value		= parent.document.form1.fechaSistema.value;
			document.form1.codAjuste.value		= parent.document.form1.codAjuste.value;
			document.form1.noAjuste.value				= parent.document.form1.noAjuste.value;
			document.form1.explicacion.value		= parent.document.form1.explicacion.value;
			document.form1.monto.value		= parent.document.form1.monto.value;
			document.form1.usuario.value		= parent.document.form1.usuario.value;
			document.form1.estado.value		= parent.document.form1.estado.value;
			document.form1.numeroDocumento.value		= parent.document.form1.numeroDocumento.value;
			document.form1.saveOption.value		= parent.document.form1.saveOption.value;


			if(calc(true))
			{
				if(document.form1.baction.value=='Guardar')document.form1.submit();
			}
			else error++;
		}
		else error++;
	}
	else error++;

	if(error>0)
	{
		parent.form1BlockButtons(false);
		form1BlockButtons(false);
		return false;
	}
}

function addAccount(objVal)
{
		setBAction('form1',objVal);
		document.form1.submit();
}

function removeDetail(k)
{
	removeItem('form1',k);
	parent.form1BlockButtons(true);
	form1BlockButtons(true);
	document.form1.submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>

<%=fb.hidden("anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("fechaDocumento","")%>
<%=fb.hidden("fechaSistema","")%>
<%=fb.hidden("codAjuste","")%>
<%=fb.hidden("noAjuste","")%>
<%=fb.hidden("explicacion","")%>
<%=fb.hidden("monto","")%>
<%=fb.hidden("usuario","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("numeroDocumento","")%>
<%=fb.hidden("saveOption","")%>

<tr class="TextHeader" align="center">

	<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Comp</cellbytelabel>.</td>
	<%if(fg.trim().equals("PO")){%>
	<td width="25%"><cellbytelabel>Cuenta</cellbytelabel></td><%}else{%>
	<td width="10%"><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
	<td width="15%"><cellbytelabel>Unidad</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Consec</cellbytelabel>.</td>
	<%}%>
	<td width="25%" align="left">Descripci&oacute;n</td>
	<td width="10%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Movimiento</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Monto Origen</cellbytelabel></td>
	<td width="5%"><%=fb.button("addAcc","+",true,viewMode,null,null,"onClick=\"javascript:addAccount(this.value)\"","Agregar Cuentas")%></td>
</tr>
<%
double totalSalida =0,totalEntrada=0;
al = CmnMgr.reverseRecords(iCta);
for (int i=1; i<=iCta.size(); i++)
{
	key = al.get(i - 1).toString();
	AjusteDetail cta = (AjusteDetail) iCta.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("key"+i,cta.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("anioA"+i,cta.getAnioA())%>
<%=fb.hidden("companiaOrigen"+i,cta.getCompaniaOrigen())%>
<%=fb.hidden("saldo"+i,cta.getDspAsignacion())%>
<%=fb.hidden("cta1"+i,cta.getCta1())%>
<%=fb.hidden("cta2"+i,cta.getCta2())%>
<%=fb.hidden("cta3"+i,cta.getCta3())%>
<%=fb.hidden("cta4"+i,cta.getCta4())%>
<%=fb.hidden("cta5"+i,cta.getCta5())%>
<%=fb.hidden("cta6"+i,cta.getCta6())%>
<%=fb.hidden("compania"+i,cta.getCompania())%>
<%=fb.hidden("numCuenta"+i,cta.getNumCuenta())%>
<%=fb.hidden("descCuenta"+i,cta.getDescCuenta())%>
<%=fb.hidden("anio"+i,cta.getAnio())%>
<%=fb.hidden("tipoInv"+i,cta.getTipoInv())%>
<%=fb.hidden("unidad"+i,cta.getCodigoUe())%>
<%=fb.hidden("descUnidad"+i,cta.getDescUnidad())%>
<%=fb.hidden("consec"+i,cta.getConsec())%>



<tr class="TextRow01" align="center">
	<td><%=cta.getAnio()%></td>
	<td><%=cta.getCompania()%></td>

	<%if(fg.trim().equals("PO")){%>
	<td><%=cta.getNumCuenta()%></td>
	<%}else{%>
	<td><%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion||' - '||a.compania||' - '||(select nombre from tbl_sec_compania where codigo =a.compania) from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInvView",cta.getTipoInv(),false,true, 0, "text10", "", "")%>		</td>
	<td><%=cta.getDescUnidad()%></td>
	<td><%=cta.getConsec()%></td>
	<%}%>

	<td align="left"><%=cta.getDescCuenta()%></td>
	<td><%=fb.textBox("mes"+i,cta.getMes(),false,false,viewMode,8,2,"Text10",null,"")%></td>
	<td><%=fb.select("movimiento"+i,"E=ENTRA,S=SALE",cta.getMovimiento(),false,viewMode,1,"Text10","","onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.decBox("montoOrigen"+i,cta.getMontoOrigen(),false,false,viewMode,20,13.2,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td align="center"><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeDetail("+i+")\"","Eliminar Cuenta")%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	AjustePresupuesto ajPres = new AjustePresupuesto();

	ajPres.setFg(fg);
	ajPres.setAnio(request.getParameter("anio"));
	ajPres.setMes(request.getParameter("mes"));
   	ajPres.setFechaSistema(request.getParameter("fechaSistema"));
	ajPres.setFechaDocumento(request.getParameter("fechaDocumento"));
	ajPres.setCodAjuste(request.getParameter("codAjuste"));
	ajPres.setExplicacion(request.getParameter("explicacion"));
	ajPres.setNoAjuste(request.getParameter("noAjuste"));
	ajPres.setEstado(request.getParameter("estado"));
	ajPres.setUsuario((String) session.getAttribute("_userName"));
	ajPres.setNumeroDocumento(request.getParameter("numeroDocumento"));
	ajPres.setMonto(request.getParameter("monto"));

	String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		AjusteDetail ajPresDet = new AjusteDetail();

		ajPresDet.setKey(request.getParameter("key"+i));
		ajPresDet.setAnio(request.getParameter("anio"+i));
		ajPresDet.setCompania(request.getParameter("compania"+i));
		ajPresDet.setMovimiento(request.getParameter("movimiento"+i));
		ajPresDet.setMontoOrigen(request.getParameter("montoOrigen"+i));
		ajPresDet.setNumCuenta(request.getParameter("numCuenta"+i));
		ajPresDet.setDescCuenta(request.getParameter("descCuenta"+i));
		ajPresDet.setMes(request.getParameter("mes"+i));

		if(fg.trim().equals("PO"))
		{
			ajPresDet.setAnioA(request.getParameter("anio"));
			ajPresDet.setCompaniaOrigen(request.getParameter("companiaOrigen"+i));
			ajPresDet.setCta1(request.getParameter("cta1"+i));
			ajPresDet.setCta2(request.getParameter("cta2"+i));
			ajPresDet.setCta3(request.getParameter("cta3"+i));
			ajPresDet.setCta4(request.getParameter("cta4"+i));
			ajPresDet.setCta5(request.getParameter("cta5"+i));
			ajPresDet.setCta6(request.getParameter("cta6"+i));
		}
		if(fg.trim().equals("PI"))
		{
			ajPresDet.setTipoInv(request.getParameter("tipoInv"+i));
			ajPresDet.setCodigoUe(request.getParameter("unidad"+i));
			ajPresDet.setDescUnidad(request.getParameter("descUnidad"+i));
			ajPresDet.setConsec(request.getParameter("consec"+i));
			ajPresDet.setAnioIm(request.getParameter("anio"+i));
		}



		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = ajPresDet.getKey();
		}
		else
		{
			try
			{
				iCta.put(ajPresDet.getKey(),ajPresDet);
				ajPres.getAjusteDetail().add(ajPresDet);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		AjusteDetail ajPresDet = (AjusteDetail) iCta.get(itemRemoved);
		if(fg.trim().equals("PO"))vCta.remove(ajPresDet.getCompania()+"-"+ajPresDet.getAnio()+"-"+ajPresDet.getMes()+"-"+ajPresDet.getCta1()+"-"+ajPresDet.getCta2()+"-"+ajPresDet.getCta3()+"-"+ajPresDet.getCta4()+"-"+ajPresDet.getCta5()+"-"+ajPresDet.getCta6());
		else if(fg.trim().equals("PO"))vCta.remove(ajPresDet.getCompania()+"-"+ajPresDet.getAnio()+"-"+ajPresDet.getMes()+"-"+ajPresDet.getCodigoUe()+"-"+ajPresDet.getConsec());
		iCta.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&fg="+fg+"&fp="+fp+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&fg="+fg+"&fp="+fp+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(mode.trim().equals("add")){AjMgr.add(ajPres); noAjuste = AjMgr.getPkColValue("noAjuste"); }
		else AjMgr.update(ajPres);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (AjMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=AjMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=AjMgr.getErrMsg()%>';
	parent.document.form1.noAjuste.value = '<%=noAjuste%>';
	parent.document.form1.submit();
	<%} else throw new Exception(AjMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
