<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.DetalleTransFormaPagos"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alForma = new ArrayList();
ArrayList alTipo = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String key = "";
int lastLineNo = 0;
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

boolean showPlus = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	alForma = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cja_forma_pago where usa in ('C', 'A') order by 2",CommonDataObject.class);
	alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cja_tipo_tarjeta where estado != 'I' order by 2",CommonDataObject.class);
	if (request.getParameter("change") == null)
	{
		iPago.clear();
		sbSql = new StringBuffer();
		sbSql.append("select a.fp_codigo as fpCodigo, a.monto, a.tipo_tarjeta as tipoTarjeta, a.num_cheque as numCheque, a.descripcion_banco as descripcionBanco, a.tipo_banco as tipoBanco, decode(a.fp_codigo,2,nvl(a.no_referencia,nvl(a.num_cheque,'')),a.no_referencia) as noReferencia from tbl_cja_trans_forma_pagos a where a.compania = ");
		sbSql.append(compania);
		sbSql.append(" and a.tran_codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and a.tran_anio = ");
		sbSql.append(anio);
		if(!codigo.trim().equals("")&&!codigo.trim().equals("0")){System.out.println("S Q L =\n"+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleTransFormaPagos.class);}
		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			DetalleTransFormaPagos det = (DetalleTransFormaPagos) al.get(i - 1);
			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			det.setKey(key);
			iPago.put(key,det);
		}
	}
	else
	{
		al = CmnMgr.reverseRecords(iPago);
		for (int i=1; i<=iPago.size(); i++)
		{
			key = al.get(i - 1).toString();
			DetalleTransFormaPagos det = (DetalleTransFormaPagos) iPago.get(key);
			if (det.getFpCodigo().equalsIgnoreCase("0")) showPlus = false;
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Formas de Pago - '+document.title;
function doAction(){newHeight();checkFormaPago('');for(i=1;i<=<%=iPago.size()%>;i++)checkFormaPago(i);calcTotal();}
function checkFormaPago(k){var fpCodigo=eval('document.formFP.fpCodigo'+k).value;var bMonto=true;var bTipoTarjeta=true;var bNoReferencia=true;var bDescripcionBanco=true;var bTipoBanco=true;var clearValue=true;if(fpCodigo=='0'){bMonto=false;bNoReferencia=false;clearValue=false;getRecibo(k);}else if(fpCodigo=='2'){bMonto=false;bTipoTarjeta=true;bNoReferencia=false;bDescripcionBanco=false;bTipoBanco=false;}else if(fpCodigo=='3'||fpCodigo=='6'){bMonto=false;bTipoTarjeta=false;bNoReferencia=false;bDescripcionBanco=true;bTipoBanco=true;}else if(fpCodigo=='1'){bMonto=false;bTipoTarjeta=true;bNoReferencia=true;bDescripcionBanco=true;bTipoBanco=true;}else if(fpCodigo!=''){bMonto=false;bTipoTarjeta=true;bNoReferencia=false;bDescripcionBanco=true;bTipoBanco=true;}if(bMonto&&clearValue)eval('document.formFP.monto'+k).value='';if(bTipoTarjeta)eval('document.formFP.tipoTarjeta'+k).value='';if(bNoReferencia&&clearValue)eval('document.formFP.noReferencia'+k).value='';if(bDescripcionBanco)eval('document.formFP.descripcionBanco'+k).value='';if(bTipoBanco)eval('document.formFP.tipoBanco'+k).value='';eval('document.formFP.monto'+k).readOnly=(!bMonto)?<%=(viewMode || !fg.trim().equals(""))%>:bMonto;eval('document.formFP.tipoTarjeta'+k).disabled=(!bTipoTarjeta)?<%=(viewMode || !fg.trim().equals(""))%>:bTipoTarjeta;eval('document.formFP.noReferencia'+k).readOnly=(!bNoReferencia)?<%=(viewMode || !fg.trim().equals(""))%>:bNoReferencia;eval('document.formFP.descripcionBanco'+k).readOnly=(!bDescripcionBanco)?<%=(viewMode || !fg.trim().equals(""))%>:bDescripcionBanco;eval('document.formFP.tipoBanco'+k).disabled=(!bTipoBanco)?<%=(viewMode || !fg.trim().equals(""))%>:bTipoBanco;eval('document.formFP.monto'+k).className='Text10 '+(bMonto?'FormDataObjectDisabled':'FormDataObjectRequired');eval('document.formFP.tipoTarjeta'+k).className='Text10 '+(bTipoTarjeta?'FormDataObjectDisabled':'FormDataObjectRequired');eval('document.formFP.noReferencia'+k).className='Text10 '+((bNoReferencia || '<%=mode%>' !='add' )?'FormDataObjectDisabled':'FormDataObjectRequired');eval('document.formFP.descripcionBanco'+k).className='Text10 '+(bDescripcionBanco?'FormDataObjectDisabled':'FormDataObjectRequired');eval('document.formFP.tipoBanco'+k).className='Text10 '+(bTipoBanco?'FormDataObjectDisabled':'FormDataObjectRequired');}
function isValidFormaPago(k){var fpCodigo=eval('document.formFP.fpCodigo'+k).value;var monto=(eval('document.formFP.monto'+k).value.trim()=='')?0:parseFloat(eval('document.formFP.monto'+k).value);var tipoTarjeta=eval('document.formFP.tipoTarjeta'+k).value;var noReferencia=eval('document.formFP.noReferencia'+k).value;var descripcionBanco=eval('document.formFP.descripcionBanco'+k).value;var tipoBanco=eval('document.formFP.tipoBanco'+k).value;if(fpCodigo=='0'){if(noReferencia.trim()==''){getRecibo(k);}}else if(fpCodigo=='2'){if(noReferencia.trim()==''&& "<%=mode%>"=="add"){eval('document.formFP.noReferencia'+k).focus();alert('Por favor introduzca el Número de Cheque!');return false;}else if(descripcionBanco.trim()==''&& "<%=mode%>"=="add"){eval('document.formFP.descripcionBanco'+k).focus();alert('Por favor introduzca el Banco!');return false;}else if(tipoBanco.trim()==''&& '<%=mode%>'=='add'){eval('document.formFP.tipoBanco'+k).focus();alert('Por favor introduzca el Tipo de Banco!');return false;}}else if((fpCodigo=='3'||fpCodigo=='6')&& '<%=mode%>'=='add'){
  if(tipoTarjeta=='' && (fpCodigo=='3'||fpCodigo=='6')){eval('document.formFP.tipoTarjeta'+k).focus();alert('Por favor seleccione el Tipo de Tarjeta!');return false;}
  else if(noReferencia.trim()==''&& "<%=mode%>"=="add"){eval('document.formFP.noReferencia'+k).focus();alert('Por favor introduzca el Número de Referencia!'+k);return false;}
}else if(fpCodigo==''){alert('Por favor seleccione la Forma de Pago!');return false;}else if(document.formFP.baction.value=='+'&&monto<=0){alert('Por favor introduzca un Monto válido!');return false;}return true;}
function calcTotal(){var total=0.00;for(i=1;i<=<%=iPago.size()%>;i++)if(eval('document.formFP.monto'+i).value.trim()!=''&&!isNaN(eval('document.formFP.monto'+i).value)){var monto=parseFloat(eval('document.formFP.monto'+i).value);total+=monto;eval('document.formFP.monto'+i).value=monto.toFixed(2);}if(parent.window.document.form0.pagoTotal)parent.window.document.form0.pagoTotal.value=total.toFixed(2);var aplicado=(parent.window.document.form0.aplicadoDisplay)?parseFloat(parent.window.document.form0.aplicadoDisplay.value):0;var ajustado=(parent.window.document.form0.ajustado)?parseFloat(parent.window.document.form0.ajustado.value):0;var porAplicar=total-aplicado+ajustado;if(parent.window.document.form0.porAplicar)parent.window.document.form0.porAplicar.value=porAplicar.toFixed(2);<%if(mode.trim().equals("add")){%>if(parent.window.frames['detalle'].updSaldoAlq)parent.window.frames['detalle'].updSaldoAlq();<%}%>if(parent.window.frames['detalle'].calcTotal)parent.window.frames['detalle'].calcTotal();}
function isValid(baction){document.formFP.baction.value=baction;if(document.formFP.keySize.value<=0){alert('Por favor agregue por lo menos una Forma de Pago!');return false;}for(i=1;i<=document.formFP.keySize.value;i++)if(!isValidFormaPago(i))return false;return formFPValidation();}
function addBillSerie(){parent.showPopWin('../caja/reg_recibo_billete.jsp?fg=<%=fg%>&mode=<%=mode%>&compania=<%=compania%>&anio=<%=anio%>&codigo=<%=codigo%>',winWidth*.75,winHeight*.75,null,null,'');}
function getRecibo(k){<% if (iPago.size() == 0) { %>var fpCodigo=eval('document.formFP.fpCodigo'+k).value;if(fpCodigo=='0'){parent.window.document.form0.remplazo.value='S';var refId=parent.window.document.form0.refId.value;var turno=parent.window.document.form0.turno.value;if(parent.window.document.form0.nombre.value==''){resetFormaPago(k);alert('Por favor seleccione el Cliente!');}else if(turno==''){resetFormaPago(k);alert('Usted no tiene un Turno válido!');}else if(eval('document.formFP.monto'+k).value==''&&eval('document.formFP.noReferencia'+k).value==''){parent.showPopWin('../common/search_recibo.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&refId='+refId+'&turno='+turno+'&idx='+k,winWidth*.95,winHeight*.75,null,false,'');}else{resetFormaPago(k);}}<% } %>}
function isRecibo(obj,k){var fpCodigo=eval('document.formFP.fpCodigo'+k).value;if(fpCodigo=='0'){parent.window.document.form0.remplazo.value='S';obj.blur();}}
function resetFormaPago(k){eval('document.formFP.fpCodigo'+k).value='';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formFP",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document.formFP.baction.value!='Guardar')if(document.formFP.baction.value=='+'&&document.formFP.fpCodigo.value==''){alert('Por favor seleccione la Forma de Pago!');error++;}else return true;");%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+iPago.size())%>
		<tr class="TextHeader" align="center">
			<td width="15%">Forma Pago</td>
			<td width="8%">Monto</td>
			<td width="19%">Tipo Tarjeta</td>
			<td width="14%"># Cheque / Referencia</td>
			<td width="19%">Banco</td>
			<td width="10%">Tipo Banco</td>
			<td width="3%"><%=fb.button("btnBillSerie","$",true,false,"Text10",null,"onClick=\"javascript:addBillSerie()\"","Agregar Denominaciones / Series")%></td>
		</tr>
		<tr class="TextHeader02" align="center">
			<td><%=fb.select("fpCodigo",alForma,"",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,"onChange=\"javascript:checkFormaPago('');\"",null,"S")%></td>
			<td><%=fb.decPlusBox("monto","",false,false,(viewMode || !fg.trim().equals("")),10,12.2,"Text10","","onFocus=\"javascript:isRecibo(this,'');\"")%></td>
			<td><%=fb.select("tipoTarjeta",alTipo,"",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%=fb.textBox("noReferencia","",false,false,(viewMode || !fg.trim().equals("")),20,20,"Text10","","onFocus=\"javascript:isRecibo(this,'');\"")%></td>
			<td><%=fb.textBox("descripcionBanco","",false,false,(viewMode || !fg.trim().equals("")),35,100,"Text10","","")%></td>
			<td><%=fb.select("tipoBanco","L=LOCAL,E=EXTRANJERO","",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%=(showPlus)?fb.submit("agregar","+",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Forma Pago"):"&nbsp;"%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iPago);
for (int i=1; i<=iPago.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleTransFormaPagos det = (DetalleTransFormaPagos) iPago.get(key);
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center">
			<td>
				<%=fb.hidden("fpCodigo"+i,det.getFpCodigo())%>
				<%=fb.select("fpCodigoDisplay"+i,alForma,det.getFpCodigo(),false,true,0,"Text10",null,"",null,"")%>
			</td>
			<td><%=fb.decPlusZeroBox("monto"+i,det.getMonto(),true,false,(viewMode || !fg.trim().equals("")),10,12.2,"Text10","","onBlur=\"javascript:calcTotal();\" onFocus=\"javascript:isRecibo(this,'"+i+"');\"")%></td>
			<td><%=fb.select("tipoTarjeta"+i,alTipo,det.getTipoTarjeta(),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%=fb.textBox("noReferencia"+i,det.getNoReferencia(),false,false,(viewMode || !fg.trim().equals("")),20,20,"Text10","","onFocus=\"javascript:isRecibo(this,'"+i+"');\"")%></td>
			<td><%=fb.textBox("descripcionBanco"+i,det.getDescripcionBanco(),false,false,(viewMode || !fg.trim().equals("")),35,100,"Text10","","")%></td>
			<td><%=fb.select("tipoBanco"+i,"L=LOCAL,E=EXTRANJERO",det.getTipoBanco(),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%=fb.submit("rem"+i,"X",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
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
else
{
	String baction = request.getParameter("baction");
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	String itemRemoved = "";
	//solo para cuando registran nuevo recibo
	if (fg.trim().equals(""))
	{
		for (int i=1; i<=keySize; i++)
		{
			DetalleTransFormaPagos det = new DetalleTransFormaPagos();

			det.setFpCodigo(request.getParameter("fpCodigo"+i));
			det.setMonto(request.getParameter("monto"+i));
			det.setTipoTarjeta(request.getParameter("tipoTarjeta"+i));
			det.setTipoBanco(request.getParameter("tipoBanco"+i));
			det.setNoReferencia(request.getParameter("noReferencia"+i));
			det.setDescripcionBanco(request.getParameter("descripcionBanco"+i));
			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).trim().equals("")) itemRemoved = det.getKey();
			try
			{
				iPago.put(det.getKey(),det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		iPago.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&mode="+mode+"&tipoCliente="+tipoCliente+"&compania="+compania+"&anio="+anio+"&codigo="+codigo+"&change=1&lastLineNo="+lastLineNo);
		return;
	}
	else if (baction.equals("+"))
	{
		DetalleTransFormaPagos det = new DetalleTransFormaPagos();
		det.setFpCodigo(request.getParameter("fpCodigo"));
		det.setMonto(request.getParameter("monto"));
		det.setTipoTarjeta(request.getParameter("tipoTarjeta"));
		det.setNoReferencia(request.getParameter("noReferencia"));
		det.setDescripcionBanco(request.getParameter("descripcionBanco"));
		det.setTipoBanco(request.getParameter("tipoBanco"));

		lastLineNo++;
		if (lastLineNo < 10) key = "00"+lastLineNo;
		else if (lastLineNo < 100) key = "0"+lastLineNo;
		else key = ""+lastLineNo;
		det.setKey(key);

		try
		{
			iPago.put(key,det);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&mode="+mode+"&tipoCliente="+tipoCliente+"&compania="+compania+"&anio="+anio+"&codigo="+codigo+"&change=1&lastLineNo="+lastLineNo);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.window.frames['detalle'].doSubmit('<%=baction%>');window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&compania=<%=compania%>&anio=<%=anio%>&codigo=<%=codigo%>&change=1&lastLineNo=<%=lastLineNo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>