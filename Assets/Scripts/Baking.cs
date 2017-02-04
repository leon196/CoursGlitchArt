using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baking : MonoBehaviour
{
	private MeshFilter meshFilter;
	private Texture2D positionTexture;
	private int width = 512;
	private int height = 512;

	public float length = 8f;
	public float radius = 2f;
	public Texture colorTexture;
	public Texture normalTexture;
	public Texture brushTexture;
	private Vector3 position;
	private ShaderPass shaderPass;
	private RaycastHit hit;
	private float radiusDelta;

	void Start ()
	{
		radiusDelta = radius;
		meshFilter = GetComponentInChildren<MeshFilter>();
		shaderPass = GetComponentInChildren<ShaderPass>();
		// shaderPass.Print(colorTexture as Texture2D);
		positionTexture = new Texture2D(width, height, TextureFormat.RGBAFloat, false);
		BakeBackground();
		BakePosition();
	}

	void BakeBackground ()
	{
		Color[] colors = new Color[width*height];
		for (int x = 0; x < width; ++x) {
			for (int y = 0; y < height; ++y) {
				int index = x + y * width;
				float c = index/(float)colors.Length;
				colors[index] = new Color(c,c,c,1f);
			}
		}
		positionTexture.SetPixels(colors);
		positionTexture.Apply(false);
	}

	void BakePosition ()
	{
		Mesh mesh = meshFilter.sharedMesh;
		Vector3[] vertices = mesh.vertices;
		Vector2[] uvs = mesh.uv;
		int[] triangles = mesh.triangles;
		int triCount = triangles.Length;
		Color[] colors = new Color[width*height];
		for (int tri = 0; tri < triCount; tri += 3) {
			Vector3 vertexA = vertices[triangles[tri]];
			Vector3 vertexB = vertices[triangles[tri+1]];
			Vector3 vertexC = vertices[triangles[tri+2]];
			Vector3 vertexCenter = (vertexA+vertexB+vertexC)/3f;
			Vector2 uvA = uvs[triangles[tri]];
			Vector2 uvB = uvs[triangles[tri+1]];
			Vector2 uvC = uvs[triangles[tri+2]];
			// Vector2 uvCenter = (uvA+uvB+uvC)/3f;
			int minX = (int)(Mathf.Min(uvA.x, Mathf.Min(uvB.x, uvC.x)) * width);
			int maxX = (int)(Mathf.Max(uvA.x, Mathf.Max(uvB.x, uvC.x)) * width);
			int minY = (int)(Mathf.Min(uvA.y, Mathf.Min(uvB.y, uvC.y)) * height);
			int maxY = (int)(Mathf.Max(uvA.y, Mathf.Max(uvB.y, uvC.y)) * height);
			float areaTotal = TriangleArea(uvA, uvB, uvC);
			for (int pixelX = minX; pixelX <= maxX; ++pixelX) {
				for (int pixelY = minY; pixelY <= maxY; ++pixelY) {
					Vector2 uv = new Vector2(pixelX/(float)width, pixelY/(float)height); 
					float areaA = TriangleArea(uv, uvB, uvC) / areaTotal;
					float areaB = TriangleArea(uv, uvA, uvC) / areaTotal;
					float areaC = TriangleArea(uv, uvA, uvB) / areaTotal;
					// Vector3 vertex = Vector3.Lerp(Vector3.Lerp(Vector3.Lerp(vertexA, vertexC, areaC), vertexB, areaB), vertexA, areaA);
					Vector3 vertex = vertexCenter + (vertexA-vertexCenter)*areaA + (vertexB-vertexCenter)*areaB + (vertexC-vertexCenter)*areaC;
					int index = pixelX + pixelY * width;
					colors[index] = new Color(vertex.x, vertex.y, vertex.z);
				}
			}
		}
		positionTexture.SetPixels(colors);
		positionTexture.Apply(false);
	}
	
	void Update ()
	{

		radiusDelta = Mathf.Clamp(radiusDelta - Input.GetAxis("Mouse ScrollWheel"), 0.1f, 5f);
		radius = Mathf.Lerp(radius, radiusDelta, Time.deltaTime*5f);

    Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

		if (Physics.Raycast(ray.origin, ray.direction, out hit)) {
			position = hit.point;
		} else {
			position = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, length));
		}
		
		Shader.SetGlobalTexture("_ColorTexture", colorTexture);
		Shader.SetGlobalTexture("_NormalTexture", normalTexture);
		Shader.SetGlobalTexture("_PositionTexture", positionTexture);
		Shader.SetGlobalTexture("_BrushTexture", brushTexture);
		Shader.SetGlobalVector("_SpherePosition", position);
		Shader.SetGlobalFloat("_SphereRadius", radius);
		Shader.SetGlobalFloat("_InputMouseLeft", Input.GetMouseButton(0) ? 1f : 0f);
		Shader.SetGlobalFloat("_InputMouseRight", Input.GetMouseButton(1) ? 1f : 0f);
		Shader.SetGlobalMatrix("_MatrixWorldToLocal", transform.worldToLocalMatrix);
		Shader.SetGlobalVector("_TransformPosition", transform.position);
	}

	void OnDrawGizmos ()
	{
		Gizmos.DrawWireSphere(position, radius);
	}

	// http://stackoverflow.com/questions/10947885/calculation-the-area-of-a-triangle
	float TriangleArea (Vector2 a, Vector2 b, Vector2 c)
	{
		float valueA = a.magnitude;
		float valueB = b.magnitude;
		float valueC = c.magnitude;
		float i = (valueA + valueB + valueC) / 2f;
		return Mathf.Sqrt(i * (i - valueA) * (i - valueB) * (i - valueC));
	}

	float TriangleArea (Vector3 a, Vector3 b, Vector3 c)
	{
		return Vector3.Cross(a - b, a - c).magnitude / 2f;
	}
}
