<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.PagoAutoFacAxa"%>
<%@ page import="issi.caja.PagoFacAxaDet"%>
<%@ page import="issi.caja.PagoAutoFacAxaMgr"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="vRecibos" scope="session" class="java.util.Vector" />
<jsp:useBean id="iReciboAxa" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="PAMgr" scope="page" class="issi.caja.PagoAutoFacAxaMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PAMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String secuencia = request.getParameter("secuencia");
String anio = request.getParameter("anio");
String key = "";
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
boolean viewMode = false;
int reciboLastLineNo = 0;
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getParameter("reciboLastLineNo") != null && !request.getParameter("reciboLastLineNo").equals("")) reciboLastLineNo = Integer.parseInt(request.getParameter("reciboLastLineNo"));
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Recibos para Pagos Axa - '+document.title;

function doSubmit()
{
	 document.form1.fin_total.value = parent.document.form0.fin_total.value;
	 document.form1.monto_inasa.value = parent.document.form0.monto_inasa.value;
	 document.form1.anio.value = parent.document.form0.anio.value;
   document.form1.monto_capitation.value = parent.document.form0.monto_capitation.value;
	 document.form1.monto_recibo.value = parent.document.form0.monto_recibo.value;
   document.form1.cod_empresa.value = parent.document.form0.empresa.value;
	 document.form1.fecha_inicial.value = parent.document.form0.fecha_ini.value;
   document.form1.fecha_final.value = parent.document.form0.fecha_fin.value;
   document.form1.monto_pendiente.value = parent.document.form0.monto_pendiente.value;
   document.form1.total_facturado.value = parent.document.form0.total_facturado.value;
	 document.form1.total_pagado.value = parent.document.form0.total_pagado.value;
   document.form1.total_ajustado.value = parent.document.form0.total_ajustado.value;
	 document.form1.factura_corte.value = parent.document.form0.factura_corte.value;
	 if(parent.document.form0.aplicar_perdida.checked)
	 document.form1.aplicar_perdida.value = "S";
	 else document.form1.aplicar_perdida.value = "N";
	 if(parent.document.form0.aplicar_pago.checked)
	 document.form1.aplicar_pago.value = "S";
	 else document.form1.aplicar_pago.value = "N";

  if(document.form1.keySize.value=="0" || document.form1.keySize.value=="")
	{
		alert('Agregue por lo menos un Recibos');
		doAction();
		return false;
	}
	setTotales();
	/*if(parseFloat(parent.document.form0.fin_total.value) != parseFloat(parent.document.form0.monto_inasa.value))
	{
			alert('Revise los Montos ');
			doAction();
			return false;
	}*/
	if (!form1Validation())
	{
		parent.form0BlockButtons(false);
		return false;
	}
	 document.form1.submit();
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
function doAction()
{
		parent.form0BlockButtons(false);
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	setTotales();
	<%
	if (request.getParameter("type") != null)
	{
%>
	showRecibos();
<%
	}
%>
}
function showRecibos()
{
//abrir_ventana1('../common/search_empresa.jsp?fp=pago_automatico');

}
function checkRecibos(k)
{
var codigo = eval('document.form1.recibo'+k).value;
var anio = '<%=anio%>';
var r =  splitRowsCols(getDBData('<%=request.getContextPath()%>','to_char(b.fecha,\'dd/mm/yyyy\'), b.pago_total','tbl_cja_recibos a, tbl_cja_transaccion_pago b','a.compania = b.compania  and a.ctp_anio = b.anio and a.ctp_codigo = b.codigo and a.codigo=\''+codigo+'\'  and b.rec_status  = \'A\' and a.compania= <%=(String) session.getAttribute("_companyId")%>' ,''));

	//alert(r.length);

 if (r== null || r.length == 0)
 {
		alert(' El recibo No Existe!');
		eval('document.form1.recibo'+k).value="";
 } else
 {
 		eval('document.form1.fecha'+k).value = r[0][0];
 		eval('document.form1.monto'+k).value = r[0][1];
 }

/*if(!hasDBData('<%=request.getContextPath()%>','tbl_cja_recibos','codigo=\''+codigo+'\' and ctp_anio='+anio+'\' and compania='+<%=(String) session.getAttribute("_userName")%>,''))
{
	alert(' El recibo No Existe!');
	eval('document.form1.recibo'+k).value="";
}*/
}
function BtnAct()
{
	parent.form0BlockButtons(false);
}

function setTotales()
{
		var total =0;
		var size1 = parseInt(document.getElementById("keySize").value);
		for (i=0;i<size1;i++)
		{
			if(eval('document.form1.monto'+i).value!="")
				total += parseFloat(eval('document.form1.monto'+i).value);
		}
		parent.document.form0.fin_total.value = total.toFixed(2);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' )return true;");%>

			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("v_baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("reciboLastLineNo",""+reciboLastLineNo)%>
			<%=fb.hidden("keySize",""+iReciboAxa.size())%>
			<%=fb.hidden("secuencia",secuencia)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("monto_capitation","")%>
			<%=fb.hidden("numero_recibo","")%>
			<%=fb.hidden("monto_recibo","")%>
			<%=fb.hidden("cod_empresa","")%>
			<%=fb.hidden("fecha_inicial","")%>
			<%=fb.hidden("fecha_final","")%>
			<%=fb.hidden("monto_pendiente","")%>
			<%=fb.hidden("total_facturado","")%>
			<%=fb.hidden("total_pagado","")%>
			<%=fb.hidden("total_ajustado","")%>
			<%=fb.hidden("factura_corte","")%>
			<%=fb.hidden("aplicar_perdida","")%>
			<%=fb.hidden("aplicar_pago","")%>
			<%=fb.hidden("monto_inasa","")%>
			<%=fb.hidden("fin_total","")%>
			<tr class="TextHeader" align="center">
				<td width="30%"><cellbytelabel>Recibo</cellbytelabel></td>
				<td width="30%"><cellbytelabel>Fecha</cellbytelabel></td>
				<td width="30%"><cellbytelabel>Monto</cellbytelabel></td>
				<td width="10%"><%=fb.submit("agregar","+",true,(viewMode || iReciboAxa.size()==5),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
		</tr>
				<%
				    al = CmnMgr.reverseRecords(iReciboAxa);
				    for (int i = 0; i < iReciboAxa.size(); i++)
				    {
					  key = al.get(i).toString();
					  PagoFacAxaDet pFa = (PagoFacAxaDet) iReciboAxa.get(key);
						String color = "TextRow02";
	 					if (i % 2 == 0) color = "TextRow01";
			    %>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("compania"+i,pFa.getCompania())%>
				<tr class="<%=color%>" align="center">
				<td><%=fb.textBox("recibo"+i,pFa.getRecibo(),true,false,false,10,12,null,null,"onBlur=\"javascript:checkRecibos("+i+")\"")%></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
											<jsp:param name="valueOfTBox1" value="<%=pFa.getFecha()%>" />
											</jsp:include></td>

				<td>&nbsp;&nbsp;&nbsp;<%=fb.decBox("monto"+i,pFa.getMonto(),true,false,viewMode,15,15.2,null,null,"onBlur=\"javascript:setTotales()\"")%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
				<%}%>
				<%fb.appendJsValidation("if(error>0)doAction();");%>

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
		int keySize=Integer.parseInt(request.getParameter("keySize"));
	  mode = request.getParameter("mode");
		anio = request.getParameter("anio");
	  reciboLastLineNo = Integer.parseInt(request.getParameter("reciboLastLineNo"));
	  ArrayList list = new ArrayList();
	  String ItemRemoved = "";
		System.out.println("en el post ---anio--"+anio);
		System.out.println("----baction----"+request.getParameter("baction"));

		PagoAutoFacAxa pAxa = new PagoAutoFacAxa();
	  for (int i=0; i<keySize; i++)
	  {
	    PagoFacAxaDet pDet = new PagoFacAxaDet();

				if(i<5)
				{
						if(i==0)
						{
							pAxa.setRec1Numero(request.getParameter("recibo"+i));
		 				  pAxa.setRec1Monto(request.getParameter("monto"+i));
						}
						else if(i==1)
						{
							pAxa.setRec2Numero(request.getParameter("recibo"+i));
		 				  pAxa.setRec2Monto(request.getParameter("monto"+i));
						}
						else if(i==2)
						{
							pAxa.setRec3Numero(request.getParameter("recibo"+i));
		 				  pAxa.setRec3Monto(request.getParameter("monto"+i));
						}
						else if(i==3)
						{
							pAxa.setRec4Numero(request.getParameter("recibo"+i));
		 				  pAxa.setRec4Monto(request.getParameter("monto"+i));
						}
						else if(i==4)
						{
							pAxa.setRec5Numero(request.getParameter("recibo"+i));
		 				  pAxa.setRec5Monto(request.getParameter("monto"+i));
						}

				}
			 pDet.setRecibo(request.getParameter("recibo"+i));
			 pDet.setMonto(request.getParameter("monto"+i));
			 pDet.setFecha(request.getParameter("fecha"+i));
			 pDet.setCompania(request.getParameter("compania"+i));

	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
		  ItemRemoved = key;
		}
		else
		{
	      try{
		        iReciboAxa.put(key,pDet);
						vRecibos.add(pDet.getRecibo());
						pAxa.addDetallePagoAxa(pDet);
		        list.add(pDet);
		     }catch(Exception e){ System.err.println(e.getMessage()); }
	    }
	  }	//for

	  if (!ItemRemoved.equals(""))
	  {
			 vRecibos.remove(((PagoFacAxaDet) iReciboAxa.get(ItemRemoved)).getRecibo());
			 iReciboAxa.remove(ItemRemoved);
			 response.sendRedirect("../caja/pago_axa_det.jsp?mode="+mode+"&reciboLastLineNo="+reciboLastLineNo);
			 return;
	  }

	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {

				PagoFacAxaDet det = new PagoFacAxaDet();
				det.setRecibo("");
				det.setMonto("");
				det.setFecha(cDateTime.substring(0,10));
				det.setCompania((String) session.getAttribute("_companyId"));
				reciboLastLineNo++;
				if (reciboLastLineNo < 10) key = "00" +reciboLastLineNo;
				else if (reciboLastLineNo < 100) key = "0" +reciboLastLineNo;
				else key = "" +reciboLastLineNo;
				det.setKey(key);
				try
				{
						iReciboAxa.put(key,det);
				}
				catch(Exception e)
				{
						System.err.println(e.getMessage());
				}
		 response.sendRedirect("../caja/pago_axa_det.jsp?anio="+anio+"&mode="+mode+"&reciboLastLineNo="+reciboLastLineNo);
		 return;
	  }
   	 //status


		 pAxa.setCompania((String) session.getAttribute("_companyId"));
		 pAxa.setCodEmpresa(request.getParameter("cod_empresa"));
		 pAxa.setPagarInasa(request.getParameter("monto_inasa"));
		 pAxa.setTotales(request.getParameter("fin_total"));
		 pAxa.setFechaInicial(request.getParameter("fecha_inicial"));
		 pAxa.setFechaFinal(request.getParameter("fecha_final"));

		 pAxa.setNumeroRecibo(request.getParameter("numero_recibo"));
		 pAxa.setMontoRecibo(request.getParameter("monto_recibo"));
		 pAxa.setMontoPendiente(request.getParameter("monto_pendiente"));
		 pAxa.setTotalFacturado(request.getParameter("total_facturado"));
		 pAxa.setTotalPagado(request.getParameter("total_pagado"));
		 pAxa.setTotalAjustado(request.getParameter("total_ajustado"));

		 pAxa.setFacturaCorte(request.getParameter("factura_corte"));
		 pAxa.setAnio(request.getParameter("anio"));
		 pAxa.setMontoCapitation(request.getParameter("monto_capitation"));
		 if(request.getParameter("aplicar_perdida")!=null && request.getParameter("aplicar_perdida").equalsIgnoreCase("S"))
			pAxa.setAplicarPerdida("S");
		 else pAxa.setAplicarPerdida("N");
		 if(request.getParameter("aplicar_pago")!=null && request.getParameter("aplicar_pago").equalsIgnoreCase("S"))
			pAxa.setAplicarPago("S");
		 else pAxa.setAplicarPago("N");

		 pAxa.setFechaCreacion(cDateTime);
		 pAxa.setUsuarioCreacion((String) session.getAttribute("_userName"));
		 if (request.getParameter("v_baction") != null && request.getParameter("v_baction").equals("Reporte Preliminar"))
		 		pAxa.setVButton("PRELIMINAR");
		 else if (request.getParameter("v_baction") != null && request.getParameter("v_baction").equals("Pagar"))
		 		pAxa.setVButton("PAGAR");

		 if (mode.equalsIgnoreCase("add"))
		 {
			pAxa.setSecuencia("0");
			PAMgr.add(pAxa);
			secuencia = PAMgr.getPkColValue("secuencia");
		 }

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=PAMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=PAMgr.getErrMsg()%>';
  parent.document.form0.secuencia.value = '<%=secuencia%>';
	parent.document.form0.anio.value = '<%=anio%>';
  parent.document.form0.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>