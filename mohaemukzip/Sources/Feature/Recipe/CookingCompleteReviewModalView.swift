//
//  CookingCompleteReviewModalView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/29/26.
//

// MARK: - 요리 완료 확인 모달 (UI 전용)

// - 별점 1점 이상 선택 시에만 "루틴에 기록" 버튼이 주황색으로 활성화
// - onSubmit에서 상위 뷰가 요리 완료 API를 호출하도록 연결한다.
import SwiftUI

struct CookingCompleteReviewModalView: View {

    // MARK: - Properties

    @Binding var isPresented: Bool
    @Binding var selectedRating: Int

    
    let onSubmit: (Int) -> Void

    /// 제출 중 상태 (요리 완료 API 호출 중)
    /// - Note: 상위 뷰에서 주입해서 버튼/닫기 동작을 제어한다.
    let isSubmitting: Bool

    // MARK: - Init

    init(
        isPresented: Binding<Bool>,
        selectedRating: Binding<Int>,
        isSubmitting: Bool = false,
        onSubmit: @escaping (Int) -> Void
    ) {
        self._isPresented = isPresented
        self._selectedRating = selectedRating
        self.isSubmitting = isSubmitting
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 모달 배경 딤 처리
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    // 제출 중에는 실수로 닫히지 않도록 막는다.
                    guard !isSubmitting else { return }
                    isPresented = false
                }

            // 모달 카드
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    Text("요리 완료")
                        .font(.custom("Pretendard-SemiBold", size: 20))
                        .foregroundStyle(Color("grey900"))

                    // 요리사 캐릭터 (Asset: "review")
                    Image("review")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 82, height: 82)
                        .clipShape(Circle())

                    Text(
                        "요리는 성공적이었나요?\n"
                        + "방금 한 요리의 난이도를 평가하고\n"
                        + "루틴에 기록해보세요."
                    )
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color("grey900"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 6)

                    // MARK: 별점 선택 (필수)
                    StarRatingPicker(
                        selectedRating: $selectedRating,
                        maxRating: 5
                    )
                    .padding(.top, 10)
                }
                .padding(.top, 22)
                .padding(.horizontal, 20)

                // 버튼 영역
                HStack(spacing: 12) {
                    Button {
                        // 취소: 저장하지 않고 모달 닫기
                        guard !isSubmitting else { return }
                        isPresented = false
                    } label: {
                        Text("취소")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .foregroundStyle(isSubmitting ? Color("grey400") : Color("grey900"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("grey200"), lineWidth: 1)
                            )
                    }

                    Button {
                        // 요리완료: 별점이 선택된 경우에만 실행
                        guard selectedRating >= 1 else { return }
                        guard !isSubmitting else { return }
                        onSubmit(selectedRating)
                    } label: {
                        Text(isSubmitting ? "처리 중" : "요리완료")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        (selectedRating >= 1 && !isSubmitting)
                                        ? Color.orange
                                        : Color(.systemGray4)
                                    )
                            )
                    }
                    .disabled(selectedRating < 1 || isSubmitting)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 330)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
            )
        }
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - 별점 선택 컴포넌트 (★)

struct StarRatingPicker: View {

    // MARK: - Properties

    @Binding var selectedRating: Int
    let maxRating: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: selectedRating >= index ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(selectedRating >= index ? Color.orange : Color(.systemGray3))
                    .onTapGesture {
                        // 1~5점 선택
                        selectedRating = index
                    }
                    .accessibilityLabel("별점 \(index)점")
            }
        }
    }
}
