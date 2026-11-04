package com.ruoyi.web.controller.common;

import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.utils.DateUtils;

/**
 * 负载均衡测试接口
 *
 * 供 lb-lab.html 演示用：每次请求返回当前处理请求的后端实例信息，
 * 配合 Nginx upstream 可以直观看到请求被分发到了哪台后端。
 *
 * 实例标识由“主机名 + 实际监听端口”组成（如 db-backend-01:8080），
 * 同机多实例时端口不同也能区分，无需逐台配置；
 * 如需自定义可用启动参数覆盖：
 *   java -Druoyi.instance-name=node-1 -jar website.jar
 *
 * @author ruoyi
 */
@Anonymous
@RestController
@RequestMapping("/lb")
public class LbInfoController
{
    private final AtomicLong requestCount = new AtomicLong();

    private final long startedAt = System.currentTimeMillis();

    @Value("${ruoyi.instance-name:}")
    private String instanceName;

    @Value("${local.server.port:${server.port:8080}}")
    private String serverPort;

    @GetMapping("/info")
    public Map<String, Object> info(HttpServletResponse response)
    {
        long count = requestCount.incrementAndGet();

        String instanceId = resolveInstanceId();

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("instanceId", instanceId);
        data.put("hostname", getHostname());
        data.put("ip", getLocalIp());
        data.put("port", serverPort);
        data.put("pid", ManagementFactory.getRuntimeMXBean().getPid());
        data.put("uptimeSeconds", (System.currentTimeMillis() - startedAt) / 1000);
        data.put("requestCount", count);
        data.put("thread", Thread.currentThread().getName());
        data.put("serverTime", DateUtils.getTime());

        // 禁止缓存，保证每次刷新都真正打到后端
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("X-Instance-Id", instanceId);
        return data;
    }

    /**
     * 实例标识：显式配置优先，否则用“主机名:端口”。
     */
    private String resolveInstanceId()
    {
        if (instanceName != null && !instanceName.isEmpty())
        {
            return instanceName;
        }
        return getHostname() + ":" + serverPort;
    }

    private String getHostname()
    {
        try
        {
            return InetAddress.getLocalHost().getHostName();
        }
        catch (Exception e)
        {
            return "unknown";
        }
    }

    private String getLocalIp()
    {
        try
        {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements())
            {
                NetworkInterface nic = interfaces.nextElement();
                if (nic.isLoopback() || !nic.isUp())
                {
                    continue;
                }
                Enumeration<InetAddress> addresses = nic.getInetAddresses();
                while (addresses.hasMoreElements())
                {
                    InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address && !addr.isLoopbackAddress())
                    {
                        return addr.getHostAddress();
                    }
                }
            }
            return InetAddress.getLocalHost().getHostAddress();
        }
        catch (Exception e)
        {
            return "unknown";
        }
    }
}
