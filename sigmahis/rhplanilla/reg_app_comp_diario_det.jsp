<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CompMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String change = request.getParameter("change");
int lastLineNo = 0;

if (mode == null) mode = "add";
if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (fp == null || fp.trim().equals(""))fp="comp_diario";
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
	parent.form1BlockButtons(false);

<%
if (request.getParameter("type") != null)
{
%>
	var anio = parent.document.form1.ea_anio.value;
	abrir_ventana1('../contabilidad/sel_plan_ctas_comp.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&p_anio='+anio+'&lastLineNo=<%=lastLineNo%>');
<%
}
%>
	calc(false);
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalDb=0.00,totalCr=0.00;
	var size=parseInt(document.form1.size.value,10);

	for(i=1;i<=size;i++)
	{
		var typeMov=eval('document.form1.tipoMov'+i).value;
		var valor=parseFloat(eval('document.form1.valor'+i).value);
		if(typeMov=='DB')totalDb+=valor;
		else totalCr+=valor;
	}

	parent.document.form1.sumDebito.value=(totalDb).toFixed(2);
	parent.document.form1.sumCredito.value=(totalCr).toFixed(2);
	parent.document.form1.totalDb.value=(totalDb).toFixed(2);
	parent.document.form1.totalCr.value=(totalCr).toFixed(2);
	totalDb=(totalDb).toFixed(2);
	totalCr=(totalCr).toFixed(2);
	/*
	if(totalDb!=totalCr)
	{
		if(showAlert)alert('El Comprobante no está Balanceado');
		return false;
	}
	else if(totalDb==totalCr&&totalDb==0.00)
	{
		if(showAlert)alert('El Balance no puede ser igual a Cero (0)');
		return false;
	}
	*/
	return true;
}

function doSubmit()
{
	var error=0;
	var anio;
	var mes;
	var cons;
	if(parent.form1Validation())
	{
		if(form1Validation())
		{
			document.form1.baction.value 				= parent.document.form1.baction.value;
			document.form1.ea_anio.value 				= parent.document.form1.ea_anio.value;
			document.form1.mes.value						= parent.document.form1.mes.value;
			document.form1.consecutivo.value		= parent.document.form1.consecutivo.value;
			document.form1.fecha.value 					= parent.document.form1.fecha.value;
			document.form1.fechaSistema.value		= parent.document.form1.fechaSistema.value;
			document.form1.clase_comprob.value	= parent.document.form1.clase_comprob.value;
			document.form1.status.value					= parent.document.form1.status.value;
			document.form1.descripcion.value		= parent.document.form1.descripcion.value;
		//	document.form1.consecutivoCia.value	= parent.document.form1.consecutivoCia.value;

			document.form1.n_doc.value					= parent.document.form1.n_doc.value;
			document.form1.totalDb.value				= parent.document.form1.totalDb.value;
			document.form1.totalCr.value				= parent.document.form1.totalCr.value;
			document.form1.saveOption.value 		= parent.document.form1.saveOption.value;

			anio 	= parent.document.form1.ea_anio.value;
			mes		= parent.document.form1.mes.value;
			cons  	= parent.document.form1.no.value;

			if(calc())
			{
				cerrarPre(anio,mes,cons);
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
	if(parent.document.form1.ea_anio.value!='')
	{
		setBAction('form1',objVal);
		document.form1.submit();
	}
	else
	{
		alert('Por favor introduzca el año!');
		parent.document.form1.ea_anio.focus();
	}
}

function removeDetail(k)
{
	removeItem('form1',k);
	parent.form1BlockButtons(true);
	form1BlockButtons(true);
	document.form1.submit();
}

function cerrarPre(anio,mes,cons)
{
	var userMod = '<%=(String) session.getAttribute("_userName")%>';

	if(executeDB('<%=request.getContextPath()%>','update tbl_pla_pre_encab_comprob set usuario_aprob =\''+userMod+'\',fecha_a = sysdate  where compania = <%=session.getAttribute("_companyId")%> and ea_ano = '+anio+' and consecutivo = '+cons))
			{
				alert('Consecutivo Modificado');
			}
			else alert('Error al modificar el consecutivo '+cons);

}

function setRef(k)
{
	clearRef(k);
	if(eval('document.form1.refType'+k).value=='1')abrir_ventana1('../common/search_paciente.jsp?fp=asiento&index='+k);
	else if(eval('document.form1.refType'+k).value=='2')abrir_ventana1('../common/search_proveedor.jsp?fp=asiento&index='+k);
	else if(eval('document.form1.refType'+k).value=='3')abrir_ventana1('../common/search_banco.jsp?fp=asiento&index='+k);
}

function clearRef(k)
{
	eval('document.form1.refId'+k).value='';
	eval('document.form1.refDesc'+k).value='';
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

<%=fb.hidden("ea_anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("consecutivo","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("fechaSistema","")%>
<%=fb.hidden("clase_comprob","")%>
<%=fb.hidden("status","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("consecutivoCia","")%>
<%=fb.hidden("consCia","")%>
<%=fb.hidden("n_doc","")%>
<%=fb.hidden("totalDb","")%>
<%=fb.hidden("totalCr","")%>
<%=fb.hidden("saveOption","")%>
<tr class="TextHeader" align="center">
	<td width="5%">Cta1</td>
	<td width="5%">Cta2</td>
	<td width="5%">Cta3</td>
	<td width="5%">Cta4</td>
	<td width="5%">Cta5</td>
	<td width="5%">Cta6</td>
	<td width="8%">Tipo de Mov.</td>
	<td width="7%">Valor</td>
	<td width="18%">Comentario</td>
	<td width="8%">Tipo de Referencia</td>
	<td width="7%">Referencia</td>
	<td width="19%">Ref. Descripci&oacute;n</td>
	<td width="3%"><%=fb.button("addAcc","+",true,false,null,null,"onClick=\"javascript:addAccount(this.value)\"","Agregar Cuentas")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iCta);
for (int i=1; i<=iCta.size(); i++)
{
	key = al.get(i - 1).toString();
	CompDetails cta = (CompDetails) iCta.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("key"+i,cta.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("anio"+i,cta.getAnoCta())%>
<tr class="TextRow01" align="center">
	<td><%=fb.textBox("cta1"+i,cta.getCta1(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.textBox("cta2"+i,cta.getCta2(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.textBox("cta3"+i,cta.getCta3(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.textBox("cta4"+i,cta.getCta4(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.textBox("cta5"+i,cta.getCta5(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.textBox("cta6"+i,cta.getCta6(),false,false,true,3,"Text10",null,null)%></td>
	<td><%=fb.select("tipoMov"+i,"DB=DEBITO,CR=CREDITO",cta.getTipoMov(),false,false,1,"Text10","","onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.decBox("valor"+i,cta.getValor(),false,false,false,8,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.textBox("comentario"+i,cta.getComentario(),false,false,false,30,"Text10",null,null)%></td>
	<td><%=fb.select("refType"+i,"0=DIARIO,1=CXC,2=CXP,3=BANCO",cta.getRefType(),false,false,0,"Text10",null,"onChange=\"javascript:clearRef("+i+")\"")%></td>
	<td><%=fb.textBox("refId"+i,(cta.getRefId().equals("-"))?"":cta.getRefId(),false,false,true,8,"Text10",null,null)%></td>
	<td>
		<%=fb.textBox("refDesc"+i,(cta.getRefDesc().equals("-"))?"":cta.getRefDesc(),false,false,true,30,"Text10",null,null)%>
		<%=fb.button("btnRef","...",true,false,null,null,"onClick=\"javascript:setRef("+i+")\"")%>
	</td>
	<td align="center"><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+")\"","Eliminar Cuenta")%></td>
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

	Comprobante CompDet = new Comprobante();

	CompDet.setFg(fg);
	CompDet.setEaAno(request.getParameter("ea_anio"));
	CompDet.setMes(request.getParameter("mes"));
	CompDet.setConsecutivo(request.getParameter("consecutivo"));
	CompDet.setFechaCreacion(request.getParameter("fecha"));
	CompDet.setFechaSistema(request.getParameter("fechaSistema"));
	CompDet.setClaseComprob(request.getParameter("clase_comprob"));
	CompDet.setStatus(request.getParameter("status"));
	CompDet.setDescripcion(request.getParameter("descripcion"));
	CompDet.setNDoc(request.getParameter("n_doc"));
	CompDet.setConsecutivoCia(request.getParameter("consecutivoCia"));
	CompDet.setTotalDb(request.getParameter("totalDb"));
	CompDet.setTotalCr(request.getParameter("totalCr"));
	CompDet.setCompania((String) session.getAttribute("_companyId"));
	CompDet.setUsuario((String) session.getAttribute("_userName"));

	String itemRemoved = "";
	for (int i=1; i<=size; i++)
	{
		CompDetails cta = new CompDetails();

		if (!request.getParameter("cta1"+i).equals("000"))
		{

		cta.setKey(request.getParameter("key"+i));
		cta.setAnoCta(request.getParameter("ea_anio"));
		cta.setCta1(request.getParameter("cta1"+i));
		cta.setCta2(request.getParameter("cta2"+i));
		cta.setCta3(request.getParameter("cta3"+i));
		cta.setCta4(request.getParameter("cta4"+i));
		cta.setCta5(request.getParameter("cta5"+i));
		cta.setCta6(request.getParameter("cta6"+i));
		cta.setDescripcion(request.getParameter("descripcion"+i));
		cta.setTipoMov(request.getParameter("tipoMov"+i));
		cta.setValor(request.getParameter("valor"+i));
		cta.setComentario(request.getParameter("comentario"+i));
		cta.setRecibeMov(request.getParameter("recibe_mov"+i));
		cta.setRefType(request.getParameter("refType"+i));
		if (cta.getRefType().equals("0"))
		{
			cta.setRefId("-");
			cta.setRefDesc("-");
		}
		else
		{
			cta.setRefId(request.getParameter("refId"+i));
			cta.setRefDesc(request.getParameter("refDesc"+i));
		}

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cta.getKey();
		}
		else
		{
			try
			{
				iCta.put(cta.getKey(),cta);
				CompDet.getCompDetail().add(cta);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}

		}
	}

	if (!itemRemoved.equals(""))
	{
		CompDetails cta = (CompDetails) iCta.get(itemRemoved);
		vCta.remove(cta.getCta1()+"-"+cta.getCta2()+"-"+cta.getCta3()+"-"+cta.getCta4()+"-"+cta.getCta5()+"-"+cta.getCta6());
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
		if(mode.trim().equals("add"))CompMgr.add(CompDet);
		else CompMgr.update(CompDet);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="file:///Z|/js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	parent.document.form1.errCode.value = '<%=CompMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=CompMgr.getErrMsg()%>';
	parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
