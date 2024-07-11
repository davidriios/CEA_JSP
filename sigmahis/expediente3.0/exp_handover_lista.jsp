<%@ page import="issi.admin.Properties"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%
String lista = request.getParameter("lista");
String modeSec = request.getParameter("modeSec");
if (lista == null) lista = "";
if (modeSec == null) modeSec = "add";
String desc = "VERIFICACIÓN PARA EL TRASLADO Y/O MOVIMIENTO";

boolean viewMode = modeSec.trim().equalsIgnoreCase("view");

if (lista.equals("2")) desc = "VERIFICACIÓN PARA RADIOLOGÍA";
else if (lista.equals("1")) desc = "VERIFICACIÓN PARA SALÓN DE OPERACIONES Y/O PROCEDIMIENTOS ";

Properties prop = (Properties) session.getAttribute("_prop");
issi.admin.SQLMgr SQLMgr = (issi.admin.SQLMgr) session.getAttribute("_SQLMgr");

if(prop.getProperty("reporte_transferencia") != null && !"".equals(prop.getProperty("reporte_transferencia"))){
    lista = prop.getProperty("reporte_transferencia");
}

java.util.ArrayList al = SQLMgr.getDataList("select codigo, descripcion, es_otro from tbl_sal_lista_handover where estado = 'A' and lista = "+lista+" order by orden");
%>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <tr class="bg-headtabla2">
        <td align="center">Si</td>
        <td align="center">No</td>
        <td align="center">No Aplica</td>
        <td><%=desc%></td>
        <td>OBSERVACION</td>
    </tr>
<%
for (int i = 0; i<al.size(); i++){
    CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
    <tr>
        <td align="center">
            <label class="pointer">
            <input type="radio" name="seleccionado_<%=i%>" id="seleccionado_<%=i%>"<%=viewMode?"  disabled":""%> data-index="<%=i%>"<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" data-message='Por favor indicar observaciones para: "+cdo.getColValue("descripcion")+"'":""%> class="<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" observacion_lista_null":""%>" value="SI_<%=cdo.getColValue("codigo")%>"<%=("SI_"+cdo.getColValue("codigo","0")).equals(prop.getProperty("seleccionado_"+i))?" checked":""%> onClick='shouldTypeRadioList(true, <%=i%>)'>
            </label>
        </td>
        <td align="center">
            <label class="pointer">
            <input type="radio" name="seleccionado_<%=i%>" id="seleccionado_<%=i%>"<%=viewMode?"  disabled":""%> data-index="<%=i%>"<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" data-message='Por favor indicar observaciones para: "+cdo.getColValue("descripcion")+"'":""%> class="<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" observacion_lista_null":""%>" value="NO_<%=cdo.getColValue("codigo")%>"<%=("NO_"+cdo.getColValue("codigo","0")).equals(prop.getProperty("seleccionado_"+i))?" checked":""%> onClick='shouldTypeRadioList(false, <%=i%>)'>
            </label>
        </td>
        <td align="center">
            <label class="pointer">
            <input type="radio" name="seleccionado_<%=i%>" id="seleccionado_<%=i%>"<%=viewMode?"  disabled":""%> data-index="<%=i%>"<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" data-message='Por favor indicar observaciones para: "+cdo.getColValue("descripcion")+"'":""%> class="<%=cdo.getColValue("es_otro","N").equalsIgnoreCase("Y")?" observacion_lista_null":""%>" value="NA_<%=cdo.getColValue("codigo")%>"<%=("NA_"+cdo.getColValue("codigo","0")).equals(prop.getProperty("seleccionado_"+i))?" checked":""%> onClick='shouldTypeRadioList(false, <%=i%>)'>
            </label>
        </td>
        <td>
            <%=cdo.getColValue("descripcion")%>
        </td>
        <td>
            <input type="textbox" name="observacion_lista_<%=i%>" id="observacion_lista_<%=i%>"<%=viewMode||prop.getProperty("observacion_lista_"+i).equals("")?"  readonly":""%> class="form-control input-sm" value="<%=prop.getProperty("observacion_lista_"+i)%>">
        </td>
    </tr>
<%}%>
</table>
<input type="hidden" name="tot_lista" id = "tot_lista" value="<%=al.size()%>">