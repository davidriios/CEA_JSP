<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="LE" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htFac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFac" scope="session" class="java.util.Vector" />

<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
FacMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String fact_corp = request.getParameter("fact_corp");
String appendFilter ="";
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(fg==null) fg = "mat_paciente";
if(fp==null) fp = "";
if(fact_corp==null) fact_corp = "N";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	LE = new CommonDataObject();
	if (mode.equalsIgnoreCase("add")){
		id = "0";
		LE.addColValue("fecha_creacion", fecha);
		LE.addColValue("id", id);
		LE.addColValue("lista", "0");
		LE.addColValue("enviado", "N");
		LE.addColValue("estado", "");
		LE.addColValue("fact_corp", fact_corp);
		htFac.clear();
		vFac.clear();
		session.removeAttribute("ListEnv");
	} else {
		if (id == null) throw new Exception("ID de Lista de Envio no es válida. Por favor intente nuevamente!");

		if (change==null){

		htFac.clear();
		vFac.clear();
			/*
			encabezado
			*/
			sbSql.append("select a.enviado, to_char(a.fecha_recibido, 'dd/mm/yyyy') fecha_recibido, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_modificacion, to_char(a.system_date, 'dd/mm/yyyy') system_date, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_creacion, a.enviado_por, a.comentario, a.lista, a.aseguradora, (select nombre from tbl_adm_empresa e where e.codigo = a.aseguradora) aseguradora_desc, to_char(a.fecha_envio, 'dd/mm/yyyy') fecha_envio, a.compania, a.id, a.estado, nvl(fact_corp, 'N') fact_corp from tbl_fac_lista_envio a where a.compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and a.id = ");
			sbSql.append(id);
			LE = SQLMgr.getData(sbSql.toString());

			sbSql = new StringBuffer();

			sbSql.append("select estado, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, factura, lista, lista_old, categoria, aseguradora, facturar_a, compania, secuencia, id, (select descripcion from tbl_adm_categoria_admision ca where ca.codigo = a.categoria) categoria_nombre, a.pac_id, a.admision, a.nombre_paciente, monto, rev_code, nvl((select distinct 'S' from tbl_map_cod_x_cat_adm m where m.categoria = a.categoria and m.estado = 'A' and a.aseguradora in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual)) ), 'N') show_al, nvl(join(cursor(select codigo_dgi from tbl_fac_dgi_documents d where d.compania = a.compania and d.codigo = a.factura and d.tipo_docto = 'FACT'), ','), ' ') codigo_dgi from tbl_fac_lista_envio_det a where compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and a.id = ");
			sbSql.append(id);
			al = SQLMgr.getDataList(sbSql.toString());
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				cdoDet.setKey(i);
				cdoDet.setAction("U");

				try {
					htFac.put(cdoDet.getKey(),cdoDet);
					vFac.add(cdoDet.getColValue("factura"));
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("LE",LE);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturacion - Lista de Envio - '+document.title;

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,350);}
function doSubmit(valor){window.frames['itemFrame'].doSubmit(valor);}
function addAseguradora(){
var aseg ='S';
 var size = window.frames['itemFrame'].document.form1.keySize.value;
 if(parseInt(size)>0){
 CBMSG.confirm('Al cambiar de Aseguradora se borraran los registros agregados. \n Desea continuar????',{
          cb: function(r){
            if (r=='Si'){
               window.frames['itemFrame'].clearDetail();
			   abrir_ventana1('../common/search_empresa.jsp?fp=lista_envio');
            }
          },
          btnTxt: "Si,No"
        });

    } else{abrir_ventana1('../common/search_empresa.jsp?fp=lista_envio');}
 }
function setFechaEnvio(){if(document.lista_envio.enviado.value=='S'){var fecha = getDBData('<%=request.getContextPath()%>', 'to_char(sysdate, \'dd/mm/yyyy\')', 'dual');document.lista_envio.fecha_envio.value = fecha;} else document.lista_envio.fecha_envio.value = '';}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
  <tr>
    <td class="TableBorder">
	<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%fb = new FormBean("lista_envio",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <%=fb.hidden("nuevo","S")%>
              <%=fb.hidden("fact_corp",LE.getColValue("fact_corp"))%>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Lista de Envio</cellbytelabel></td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>Id</cellbytelabel></td>
                <td>
								<%=fb.intBox("id",LE.getColValue("id"),true,false,true,10,"text10",null,"")%>
                </td>
                <td align="right"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td>
								<%=fb.hidden("aseguradora", LE.getColValue("aseguradora"))%>
								<%=fb.textBox("aseguradora_desc",LE.getColValue("aseguradora_desc"),true,false,true,50,"text10",null,"")%>
								<%=fb.button("btnAseguradora","...",true,(!mode.equals("add")),null,null,"onClick=\"javascript:addAseguradora()\"")%>
								</td>
                <td align="right"><cellbytelabel>Fecha</cellbytelabel></td>
                <td><%=fb.textBox("fecha_creacion",LE.getColValue("fecha_creacion"),true,false,true,12,"text10",null,"")%> </td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>Lista</cellbytelabel></td>
                <td>
								<%=fb.intBox("lista",LE.getColValue("lista"),false,false,true,10,"text10",null,"")%>
                </td>
                <td align="right">&nbsp;<authtype type='51'><cellbytelabel>Enviado</cellbytelabel></authtype></td>
                <td>&nbsp;<authtype type='51'><%=fb.select("enviado","N=No,S=Si", LE.getColValue("enviado"), false, false,0,"text10",null,"onChange=\"javascript:setFechaEnvio();\"")%></authtype></td>
                <td align="right"><cellbytelabel>Fecha Envio</cellbytelabel></td>
                <td><%=fb.textBox("fecha_envio",LE.getColValue("fecha_envio"),false,false,true,12,"text10",null,"")%> </td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>Comentario:</cellbytelabel></td>
                <td colspan="5">
								<%=fb.textarea("comentario",LE.getColValue("comentario"),false,false,viewMode,60,3)%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<font class="RedTextBold" size="2">
								<cellbytelabel>Estado</cellbytelabel></font><%=fb.select("estado","A=Activo,I=Inactivo", LE.getColValue("estado"), false, false,0,"text10",null,"")%>

                </td>

              </tr>


							<%
							if(LE.getColValue("enviado")!=null && (LE.getColValue("enviado").equals("S") || LE.getColValue("estado").equals("I"))){
								viewMode=true;
								mode = "view";
							}
							%>
              <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" src="../facturacion/reg_lista_envio_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id=<%=id%>&aseguradora=<%=LE.getColValue("aseguradora")%>&enviado=<%=LE.getColValue("enviado")%>"></iframe></td>
              </tr>


							<tr class="TextRow02">
								<td colspan="6" align="right">
								<cellbytelabel>Opciones de Guardar</cellbytelabel>:
								<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
								<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
								<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
								<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
								</td>
							</tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	id = request.getParameter("id");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_envio.jsp';
<%
session.removeAttribute("ListEnv");
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&tr=<%=tr%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
	///reg_sol_mat_pacientes.jsp?mode=view&id=1&anio=2009&tr=PAC_S
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
