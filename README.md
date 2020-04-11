# UnityViceShader
VJ Shader for Unity(Unity2018.4.17f1)

# Edit Shader
ViceShader.shader

## simple oscillator
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos)
{
  float4 c = float4(1, 0, 0, 1);
  float2 st = screenPos.xy/screenPos.w;
  return osc(st,75,0.05,0);
}
```

## simple shape
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos)
{
  float4 c = float4(1, 0, 0, 1);
  float2 st = screenPos.xy/screenPos.w;
  return shape(st,12,0.1,0);
}
```
