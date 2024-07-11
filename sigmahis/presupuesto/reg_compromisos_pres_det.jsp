<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Compromisos"%>
<%@ page import="issi.presupuesto.CompDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CompMgr" scope="page" class="issi.presupuesto.CompromisosMgr" />
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
CompMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String numDoc = request.getParameter("numDoc");
String change = request.getParameter("change");
int lastLineNo = 0;

boolean viewMode = false;
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

if (fg == null) throw new Exception("El flag no es válido. Por favor intente nuevamente!");
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
	var anioRef='';
	var tipoComRef='';
	var numDocRef ='';
	if(parent.document.form1.anioRef)anioRef=  parent.document.form1.anioRef.value;
	if(parent.document.form1.tipoComRef)tipoComRef=  parent.document.form1.tipoComRef.value;
	if(parent.document.form1.anioRef)numDocRef=  parent.document.form1.numDocRef.value;

	abrir_ventana1('../presupuesto/sel_presupuesto_detail.jsp?mode=<%=mode%>&fg=<%=fg%>&anio='+anio+'&numDoc=<%=numDoc%>&fp=<%=fg%>&lastLineNo=<%=lastLineNo%>&anioRef='+anioRef+'&tipoComRef='+tipoComRef+'&numDocRef='+numDocRef);
<%
}
%>
calc(false);

}

function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var montoTotal=0.00,totalEntrada=0.00;
	var size=parseInt(document.form1.size.value,10);
	var total  = 0;
	if(parent.document.form1.monto.value !='' )montoTotal=parseFloat(parent.document.form1.monto.value);
	var x=0;
	for(i=1;i<=size;i++)
	{
		var valor=parseFloat(eval('document.form1.montoOriginal'+i).value);
		var saldo =parseFloat(eval('document.form1.saldo'+i).value);

		<%if(fg.trim().equals("CF")){%>
		if (valor> saldo){   x++;
         <%if (mode != null && !mode.trim().equals("view")){%>alert('El monto a ajustar es mayor que el saldo disponible, .. VERIFIQUE !');eval('document.form1.montoOriginal'+i).value=0;valor=0; <%}%>}
		<%}%>
		total+=valor;

	}

	parent.document.form1.total.value=(total).toFixed(2);

	total=(total).toFixed(2);
	if(showAlert)
	{
			if(total==montoTotal)
			{}
			else
			{
				<%if(fg.trim().equals("CF")){%>alert('El total del monto Original, no esta en balance con el total de la inversión ...VERIFIQUE!');<%}
				else{%> alert('El monto ajustar no esta en balance con el total del ajuste ...VERIFIQUE!');<%}%>
				x++;
			}
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
			document.form1.usuario.value		= parent.document.form1.usuario.value;
			document.form1.estado.value		= parent.document.form1.estado.value;
			document.form1.explicacion.value		= parent.document.form1.explicacion.value;
			document.form1.monto.value		= parent.document.form1.monto.value;
			document.form1.fechaMod.value		= parent.document.form1.fechaMod.value;
			document.form1.usuarioMod.value		= parent.document.form1.usuarioMod.value;

			document.form1.tipoCom.value		= parent.document.form1.tipoCom.value;
			document.form1.numDoc.value		= parent.document.form1.numDoc.value;

			if(parent.document.form1.anioRef)document.form1.anioRef.value = parent.document.form1.anioRef.value;
			if(parent.document.form1.tipoComRef)document.form1.tipoComRef.value = parent.document.form1.tipoComRef.value;
			if(parent.document.form1.numDocRef)document.form1.numDocRef.value = parent.document.form1.numDocRef.value;
			if(parent.document.form1.descTipoComRef)document.form1.descTipoComRef.value = parent.document.form1.descTipoComRef.value;
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
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>

<%=fb.hidden("anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("fechaDocumento","")%>
<%=fb.hidden("fechaSistema","")%>
<%=fb.hidden("usuario","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("explicacion","")%>
<%=fb.hidden("monto","")%>

<%=fb.hidden("tipoCom","")%>
<%=fb.hidden("numDoc","")%>
<%=fb.hidden("anioRef","")%>
<%=fb.hidden("tipoComRef","")%>
<%=fb.hidden("numDocRef","")%>
<%=fb.hidden("descTipoComRef","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("fechaMod","")%>
<%=fb.hidden("usuarioMod","")%>


<tr class="TextHeader" align="center">
	<%if(fg.trim().equals("CF")){%>
	<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Comp</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
	<td width="15%"><cellbytelabel>Unidad</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Consec</cellbytelabel>.</td>
	<td width="25%" align="left">Descripci&oacute;n</td>
	<td width="10%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>

	<%}else{%>
	<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Tipo Comp</cellbytelabel>.</td>
	<td width="5%"><cellbytelabel>Num. Doc</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
	<td width="15%"><cellbytelabel>Unidad</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Consec</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Mes</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Monto Ajustado</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Monto Original</cellbytelabel></td>
	<%}%>
	<td width="5%"><%=fb.button("addAcc","+",true,viewMode,null,null,"onClick=\"javascript:addAccount(this.value)\"","Agregar Cuentas")%></td>
</tr>
<%
double totalSalida =0,totalEntrada=0;
al = CmnMgr.reverseRecords(iCta);
for (int i=1; i<=iCta.size(); i++)
{
	key = al.get(i - 1).toString();
	CompDetail cta = (CompDetail) iCta.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("key"+i,cta.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("anioCfi"+i,cta.getAnioCfi())%>
<%=fb.hidden("tipoCom"+i,cta.getTipoCom())%>
<%=fb.hidden("saldo"+i,cta.getSaldo())%>
<%=fb.hidden("numDoc"+i,cta.getNumDoc())%>
<%=fb.hidden("anio"+i,cta.getAnio())%>
<%=fb.hidden("tipoInv"+i,cta.getTipoInv())%>
<%=fb.hidden("unidad"+i,cta.getCodigoUe())%>
<%=fb.hidden("descUnidad"+i,cta.getDescUnidad())%>
<%=fb.hidden("consec"+i,cta.getConsec())%>
<%=fb.hidden("compania"+i,cta.getCompania())%>
<%=fb.hidden("descripcion"+i,cta.getDescripcion())%>
<%=fb.hidden("usuarioMod"+i,cta.getUsuarioMod())%>
<%=fb.hidden("fechaMod"+i,cta.getFechaMod())%>
<%=fb.hidden("aicAnio"+i,cta.getAicAnio())%>
<%=fb.hidden("numeroDocumento"+i,cta.getNumeroDocumento())%>
<%=fb.hidden("descTipoCom"+i,cta.getDescTipoCom())%>
<%//=fb.hidden("descTipoInv"+i,cta.getDescTipoInv())%>

 <%if(fg.trim().equals("CF")){%>

<tr class="TextRow01" align="center">
	<td><%=cta.getAnio()%></td>
	<td><%=cta.getCompania()%></td>
	<td><%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInvView",cta.getTipoInv(),false,true, 0, "text10", "", "")%>		</td>
	<td><%=cta.getDescUnidad()%></td>
	<td><%=cta.getConsec()%></td>
	<td align="left"><%=cta.getDescripcion()%></td>
	<td><%=fb.textBox("mes"+i,cta.getMes(),false,false,viewMode,8,2,"Text10",null,"")%></td>
	<td><%=fb.decBox("montoOriginal"+i,cta.getMontoOriginal(),false,false,viewMode,20,13.2,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.select("estado"+i,"COM=COMPROMETIDO,PAG=PAGADO,ANU=ANULADO",cta.getEstado(),false,viewMode,1,"Text10","","")%></td>
	<td align="center"><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeDetail("+i+")\"","Eliminar")%></td>
</tr>
<%}else{%>

<tr class="TextRow01" align="center">
	<td><%=cta.getAnio()%></td>
	<td><%=cta.getDescTipoCom()%></td>
	<td><%=cta.getNumDoc()%></td>
	<td><%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInvView",cta.getTipoInv(),false,true, 0, "text10", "", "")%>		</td>
	<td><%=cta.getDescUnidad()%></td>
	<td><%=cta.getConsec()%></td>
	<td><%=fb.textBox("mes"+i,cta.getMes(),false,false,viewMode,8,2,"Text10",null,"")%></td>
	<td><%=fb.decBox("montoOriginal"+i,cta.getMontoAjustado(),false,false,viewMode,20,13.2,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.select("estado"+i,"DB=DEBITO,CR=CREDITO,AN=ANULADO",cta.getEstado(),false,viewMode,1,"Text10","","")%></td>
	<td><%=fb.decBox("montoAjustado"+i,cta.getMontoOriginal (),false,false,viewMode,20,13.2,"Text10",null,"")%></td>
	<td align="center"><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:remove("+i+")\"","Eliminar")%></td>
</tr>

<%}
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

	Compromisos compPres = new Compromisos();

	compPres.setFg(fg);
	compPres.setAnio(request.getParameter("anio"));
	compPres.setTipoCom(request.getParameter("tipoCom"));
	compPres.setNumDoc(request.getParameter("numDoc"));
	compPres.setEstado(request.getParameter("estado"));
	compPres.setMes(request.getParameter("mes"));
	compPres.setMonto(request.getParameter("monto"));
	compPres.setFechaDocumento(request.getParameter("fechaDocumento"));
   	compPres.setFechaSistema(request.getParameter("fechaSistema"));
	compPres.setUsuario((String) session.getAttribute("_userName"));
	if(fg.trim().equals("CF")){
	compPres.setFechaMod(request.getParameter("fechaMod"));
	compPres.setUsuarioMod((String) session.getAttribute("_userName"));
	}
	compPres.setExplicacion(request.getParameter("explicacion"));

	compPres.setMontoAnterior(request.getParameter("montoAnterior"));
	compPres.setAnioRef(request.getParameter("anioRef"));
	compPres.setTipoComRef(request.getParameter("tipoComRef"));
	compPres.setNumDocRef(request.getParameter("numDocRef"));

	if(compPres.getEstado().trim().equals("COM"))compPres.setUpdateInversion("S");
      String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		CompDetail compPresDet = new CompDetail();

		compPresDet.setKey(request.getParameter("key"+i));
		compPresDet.setAnio(request.getParameter("anio"+i));
		compPresDet.setCompania(request.getParameter("compania"+i));
		compPresDet.setTipoInv(request.getParameter("tipoInv"+i));
		compPresDet.setCodigoUe(request.getParameter("unidad"+i));
		compPresDet.setDescUnidad(request.getParameter("descUnidad"+i));
		compPresDet.setConsec(request.getParameter("consec"+i));
		compPresDet.setMes(request.getParameter("mes"+i));
		compPresDet.setEstado(request.getParameter("estado"+i));
		compPresDet.setDescripcion(request.getParameter("descripcion"+i));
		compPresDet.setAnioCfi(request.getParameter("anio"));
		compPresDet.setTipoCom(request.getParameter("tipoCom"));


		//compPresDet.setDescTipoInv(request.getParameter("descTipoInv"+i));
		compPresDet.setDescTipoCom(request.getParameter("descTipoCom"+i));

		if(fg.trim().equals("CF"))
		{
			compPresDet.setMontoOriginal(request.getParameter("montoOriginal"+i));
			compPresDet.setMontoAjuste(request.getParameter("montoAjuste"+i));
			compPresDet.setUsuarioMod(request.getParameter("usuarioMod"+i));
			//compPresDet.setUsuarioMod(cDateTime);
			compPresDet.setFechaMod(request.getParameter("fechaMod"+i));
			compPresDet.setNumDoc(request.getParameter("numDoc"));

		}
		if(fg.trim().equals("AC"))
		{
			compPresDet.setMontoOriginal(request.getParameter("montoAjustado"+i));
			compPresDet.setMontoAjustado(request.getParameter("montoOriginal"+i));
			compPresDet.setAicAnio(request.getParameter("anio"));
			compPresDet.setNumeroDocumento(request.getParameter("numDoc"));
			compPresDet.setNumDoc(request.getParameter("numDoc"+i));

		}

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = compPresDet.getKey();
		}
		else
		{
			try
			{
				iCta.put(compPresDet.getKey(),compPresDet);
				compPres.getCompDetail().add(compPresDet);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		CompDetail compPresDet = (CompDetail) iCta.get(itemRemoved);


		if(fg.trim().equals("CF"))vCta.remove(compPresDet.getTipoInv()+"-"+compPresDet.getAnio()+"-"+compPresDet.getConsec()+"-"+compPresDet.getCodigoUe()+"-"+compPresDet.getCompania()+"-"+compPresDet.getMes());
		else if(fg.trim().equals("AC")) vCta.remove(compPresDet.getAnioCfi()+"-"+compPresDet.getTipoCom()+"-"+compPresDet.getNumDoc()+"-"+compPresDet.getAnio()+"-"+compPresDet.getTipoInv()+"-"+compPresDet.getCompania()+"-"+compPresDet.getCodigoUe()+"-"+compPresDet.getConsec()+"-"+compPresDet.getMes());

		iCta.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&fg="+fg+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&fg="+fg+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(mode.trim().equals("add")){CompMgr.add(compPres); numDoc = CompMgr.getPkColValue("numDoc"); }
		else CompMgr.update(compPres);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (CompMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=CompMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=CompMgr.getErrMsg()%>';
	parent.document.form1.numDoc.value = '<%=numDoc%>';
	parent.document.form1.submit();
	<%} else throw new Exception(CompMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
